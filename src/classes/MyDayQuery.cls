public with sharing class MyDayQuery 
{
	public ID viewId {get;set;}
	public String viewName {get;set;}
	public String objectName {get;set;}
	public String query {get;set;}
	
	public static List<MyDayQuery> getAll(ID userId, string namespacePrefix)
	{
		Map<String,Schema.DisplayType> fieldTypes = getFieldTypes();
		List<MyDayQuery> queries = new List<MyDayQuery>();
		List<MyDayView__c> views = [SELECT Id, Name, OwnedByMe__c, Object__c, Field__c, Operation__c, Value__c, SecondField__c, SecondOperation__c, SecondValue__c 
								FROM MyDayView__c
								WHERE OwnerId =: userId OR Private__c = FALSE ORDER BY Name];
								
		for(MyDayView__c v : views)
		{
			MyDayQuery q = new MyDayQuery();
			q.viewId = v.Id;
			q.objectName = v.Object__c;			
			q.query = buildQuery(v, fieldTypes, namespacePrefix);
			q.viewName = v.Name;
			queries.add(q);
		}
		
		return queries;
	}
	
	public static List<Schema.FieldSetMember> getAccountFields() 
	{
        return SObjectType.Account.FieldSets.MyDayAccountFieldSet.getFields();
    }
	
	public static String buildQuery(MyDayView__c view, Map<String,Schema.DisplayType> fieldTypes, string namespacePrefix)
	{
		String query = '';
		
		
		if(view.Object__c == 'Opportunity')
		{
			query = 'SELECT NextStep, Name, LastModifiedDate, Id, CloseDate, Amount, StageName, ' + namespacePrefix + 'MydayFlagged__c ' + 'FROM Opportunity WHERE ID != \'\'';
		}
		else if(view.Object__c == 'Account')
		{
			//query = 'SELECT Name, Id, Type, Phone, ' + namespacePrefix + 'MydayFlagged__c ' + 'FROM Account WHERE ID != \'\'';
			query = 'SELECT ';
			
	        for(Schema.FieldSetMember f : getAccountFields()) 
	        {
	            query += f.getFieldPath() + ', ';
	        }
	        
	        query += 'Id, MydayFlagged__c FROM Account WHERE ID != \'\'';
		}
		else
		{
			query = 'SELECT Who.Name, Who.FirstName, Who.LastName, WhoId, Subject, Status, Id, ActivityDate, ' + namespacePrefix + 'MydayFlagged__c ' + 'FROM Task WHERE ID != \'\'';
		}
		
		if(view.OwnedByMe__c)
		{
			query = query + ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';
		}
		
		if(view.Field__c != null && view.Field__c != '' )
		{
			if(view.Operation__c == 'Does Not Contain')
			{
				query = query + ' AND (NOT ' + view.Field__c + convertCriterion(view.Object__c, view.Field__c, view.Operation__c, view.Value__c, fieldTypes) + ') ';
			}
			else
			{
				query = query + ' AND ' + view.Field__c + convertCriterion(view.Object__c, view.Field__c, view.Operation__c, view.Value__c, fieldTypes);
			}
		}
		
		if(view.SecondField__c != null && view.SecondField__c != '' )
		{
			if(view.SecondOperation__c == 'Does Not Contain')
			{
				query = query + ' AND (NOT ' + view.SecondField__c + convertCriterion(view.Object__c, view.SecondField__c, view.SecondOperation__c, view.SecondValue__c, fieldTypes) + ') ';
			}
			else
			{
				query = query + ' AND ' + view.SecondField__c + convertCriterion(view.Object__c, view.SecondField__c, view.SecondOperation__c, view.SecondValue__c, fieldTypes);
			}
		}
		
		return query;
	}
	
	public static String convertCriterion(String obj, String field, String op, String value, Map<String,Schema.DisplayType> fieldTypes)
	{
		string criterion = '';
		
		Schema.DisplayType dt = fieldTypes.get(obj+field);
		Boolean isString = dt == Schema.DisplayType.ComboBox || dt == Schema.DisplayType.DataCategoryGroupReference || dt == Schema.DisplayType.Email 
			|| dt == Schema.DisplayType.EncryptedString || dt == Schema.DisplayType.ID || dt == Schema.DisplayType.MultiPicklist || dt == Schema.DisplayType.Phone 
			|| dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.Reference || dt == Schema.DisplayType.String || dt == Schema.DisplayType.TextArea 
			|| dt == Schema.DisplayType.URL;
		
		if(dt == Schema.DisplayType.MultiPicklist && op == 'Contains')
		{
			criterion = ' includes(\'' + String.escapeSingleQuotes(value) + '\')';
		}
		else if(dt == Schema.DisplayType.MultiPicklist && op == 'Does Not Contain')
		{
			criterion = ' excludes(\'' + String.escapeSingleQuotes(value) + '\')';
		}
		else if(op == 'Not Equal To')
		{
			criterion = ' != ' + (isString == true ? '\'' : '') + String.escapeSingleQuotes(value) + (isString == true ? '\'' : '');
		}
		else if(op == 'Greater or Equal')
		{
			criterion = ' >= ' + (isString == true ? '\'' : '') + String.escapeSingleQuotes(value) + (isString == true ? '\'' : '');
		}
		else if(op == 'Greater Than')
		{
			criterion = ' > ' + (isString == true ? '\'' : '') + String.escapeSingleQuotes(value) + (isString == true ? '\'' : '');
		}
		else if(op == 'Less or Equal')
		{
			criterion = ' <= ' + (isString == true ? '\'' : '') + String.escapeSingleQuotes(value) + (isString == true ? '\'' : '');
		}
		else if(op == 'Less Than')
		{
			criterion = ' < ' + (isString == true ? '\'' : '') + String.escapeSingleQuotes(value) + (isString == true ? '\'' : '');
		}
		else if(op == 'Starts With')
		{
			criterion = ' like \'' + String.escapeSingleQuotes(value) + '%\'';
		}
		else if(op == 'Ends With')
		{
			criterion = ' like \'%' + String.escapeSingleQuotes(value) + '\'';
		}
		else if(op == 'Contains' || op == 'Does Not Contain')
		{
			criterion = ' like \'%' + String.escapeSingleQuotes(value) + '%\'';
		}
		else
		{
			criterion = ' = ' + (isString == true ? '\'' : '') + value + (isString == true ? '\'' : '');
		}
		
		return criterion;
	}
	
	private static Map<String,Schema.DisplayType> getFieldTypes()
	{
		Map<String, Schema.Sobjectfield> fields = Schema.Sobjecttype.Account.fields.getMap();
		Map<String,Schema.DisplayType> fieldTypes = new Map<String,Schema.DisplayType>();
				
		for(Schema.Sobjectfield field : fields.values())
		{
			Schema.Describefieldresult fi = field.getDescribe();
			fieldTypes.put('Account' + fi.Name, fi.getType());
		}
		
		fields = Schema.Sobjecttype.Opportunity.fields.getMap();
		
		for(Schema.Sobjectfield field : fields.values())
		{
			Schema.Describefieldresult fi = field.getDescribe();
			fieldTypes.put('Opportunity' + fi.Name, fi.getType());
		}
		
		fields = Schema.Sobjecttype.Task.fields.getMap();
		
		for(Schema.Sobjectfield field : fields.values())
		{
			Schema.Describefieldresult fi = field.getDescribe();
			fieldTypes.put('Task' + fi.Name, fi.getType());
		}
		
		return fieldTypes;
	}
}