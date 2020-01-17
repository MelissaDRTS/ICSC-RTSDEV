public with sharing class MyDayViewObjectEditController 
{
	public MyDayView__c view{get;set;}
	public List<SelectOption> accountFields {get;set;}
	public List<SelectOption> oppFields {get;set;}
	public List<SelectOption> taskFields {get;set;}
	public String retUrl{get;set;}
	public String namespacePrefix{get;set;}
	public Map<String, Schema.DisplayType> fieldTypes{get;set;}
	
	public MyDayViewObjectEditController(ApexPages.StandardController controller)
	{
		String id = ApexPages.currentPage().getParameters().get('id');
		String clone = ApexPages.currentPage().getParameters().get('clone');
		
		this.namespacePrefix = MyDayUtility.GetNamespacePrefix();
		this.retURL = ApexPages.currentPage().getParameters().get('retURL');
				
		if(id == null)
		{
			this.view = new MyDayView__c();
		}
		else
		{
			this.view = [SELECT ID, Name, Object__c, Field__c, Operation__c, Value__c, SecondField__c, SecondOperation__c, SecondValue__c, Private__c, OwnedByMe__c FROM MyDayView__c WHERE ID =: id];
		
			if(clone == '1')
			{
				this.view.Id = null;
			}
		}
	}	
	
	private void validate()
	{
		List<Task> tasks = null;
		List<Account> accounts = null;
		List<Opportunity> opps = null;
		String query = '';
		List<sObject> objs = null;
				
		if(this.view.Name == null || this.view.Name == '')
		{
			throw new MyDayException('Name is required.');
		}
		
		if(this.view.Object__c == null || this.view.Object__c == '')
		{
			throw new MyDayException('Object is required.');
		}
		
		if((this.view.Field__c != null && this.view.Field__c != '' && (this.view.Operation__c == '' || this.view.Value__c == null || this.view.Value__c == null)) || 
			(this.view.Operation__c != null && this.view.Operation__c != '' && (this.view.Field__c == '' || this.view.Field__c == null || this.view.Value__c == null || this.view.Value__c == null)) ||
			(this.view.Value__c != null && this.view.Value__c != '' && (this.view.Operation__c == '' || this.view.Field__c == null || this.view.Field__c == null)))	
		{
			throw new MyDayException('All primary fields are required if a primary field is specified.');
		}
		
		if((this.view.SecondField__c != null && this.view.SecondField__c != '' && (this.view.SecondOperation__c == '' || this.view.SecondValue__c == null || this.view.SecondValue__c == null)) || 
			(this.view.SecondOperation__c != null && this.view.SecondOperation__c != '' && (this.view.SecondField__c == '' || this.view.SecondField__c == null || this.view.SecondValue__c == null || this.view.SecondValue__c == null)) ||
			(this.view.SecondValue__c != null && this.view.SecondValue__c != '' && (this.view.SecondOperation__c == '' || this.view.SecondField__c == null || this.view.SecondField__c == null)))	
		{
			throw new MyDayException('All secondary fields are required if a secondary field is specified.');
		}
				
		query = MyDayQuery.buildQuery(this.view, this.fieldTypes, namespacePrefix);
		
		query = query + ' LIMIT 1';
		
		System.Debug('Query: ' + query);
		
		objs = Database.query(query);
	}
		
	public PageReference saveAndNew()
	{	
		try
		{
			validate();
			
			upsert this.view;
			
			this.retUrl = '/apex/' + this.namespacePrefix + 'MyDayViewObjectEdit?retUrl=/' + this.view.Id; 
			
			return redirect();
		}
		catch(Exception ex)
		{
			ApexPages.addMessages(ex);	
		}
		
		return null;
	}
	
	public PageReference save()
	{
		try
		{
			validate();
			
			upsert this.view;
			
			return redirect();
		}
		catch(Exception ex)
		{
			ApexPages.addMessages(ex);	
		}
		
		return null;
	}
	
	public PageReference cancel()
	{		
		return redirect();
	}
	
	public PageReference redirect()
	{
    	PageReference returnURL;    	
 
    	if(this.retUrl != null && this.retUrl != '')
    	{
    		returnURL = new PageReference(this.retUrl);
    	}
    	else
    	{
    		returnURL = new ApexPages.StandardController(this.view).cancel();
    	}
    	
    	returnURL.setRedirect(true);
    	
    	return returnURL;
	}
	
	public List<SelectOption> getObjectFields()
	{
		Map<String, Schema.Sobjectfield> fields = null;
		
		if(fieldTypes == null)
		{
			fieldTypes = new Map<String,Schema.DisplayType>();
		}
		
		if(this.view.Object__c == 'Account')
		{
			if(this.accountFields == null)
			{
				this.accountFields = new List<SelectOption>();
				this.accountFields.add(new SelectOption('',''));
				
				fields = Schema.Sobjecttype.Account.fields.getMap();
						
				for(Schema.Sobjectfield field : fields.values())
				{
					Schema.Describefieldresult fi = field.getDescribe();
					this.accountFields.add(new SelectOption(fi.Name, fi.Label));
					
					this.accountFields = MyDayUtility.SortOptionList(this.accountFields);
					
					if(!fieldTypes.containsKey('Account' + fi.Name))
					{
						fieldTypes.put('Account' + fi.Name, fi.getType());
					}
				}
			}
			
			return this.accountFields;
		}
		else if(this.view.Object__c == 'Opportunity')
		{
			if(this.oppFields == null)
			{
				this.oppFields = new List<SelectOption>();
				this.oppFields.add(new SelectOption('',''));
				
				fields = Schema.Sobjecttype.Opportunity.fields.getMap();
			
				for(Schema.Sobjectfield field : fields.values())
				{
					Schema.Describefieldresult fi = field.getDescribe();
					this.oppFields.add(new SelectOption(fi.Name, fi.Label));
					
					this.oppFields = MyDayUtility.SortOptionList(this.oppFields);
					
					
					if(!fieldTypes.containsKey('Opportunity' + fi.Name))
					{
						fieldTypes.put('Opportunity' + fi.Name, fi.getType());
					}
				}
			
			}
			
			return this.oppFields;
		}
		else if(this.view.Object__c == 'Task')
		{
			if(this.taskFields == null)
			{
				this.taskFields = new List<SelectOption>();
				this.taskFields.add(new SelectOption('',''));
				
				fields = Schema.Sobjecttype.Task.fields.getMap();
				
				for(Schema.Sobjectfield field : fields.values())
				{
					Schema.Describefieldresult fi = field.getDescribe();
					this.taskFields.add(new SelectOption(fi.Name, fi.Label));
					
					this.taskFields = MyDayUtility.SortOptionList(this.taskFields);
					
					if(!fieldTypes.containsKey('Task' + fi.Name))
					{
						fieldTypes.put('Task' + fi.Name, fi.getType());
					}
				}
			}
			
			return this.taskFields;
		}
		else
		{
			return new List<SelectOption>();
		}
	}
}