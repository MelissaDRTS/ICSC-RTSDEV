public with sharing class ImisValidationTable 
{
	public string code{get;set;}
	public string description{get;set;}
	
	
	public static void importValues(string tableName, string endPoint, string token)
	{
		List<ImisValidationTable> imisValues = convertFromJson(ImisService.getValidationTable(endPoint, token));
		Map<String, ImisValidationTable__c> sfValues = ImisValidationTable__c.getAll();
		List<ImisValidationTable__c> newSfValues = new List<ImisValidationTable__c>();
		
		if(!imisValues.isEmpty())
		{
			for(ImisValidationTable ivt : imisValues)
			{
				ImisValidationTable__c val = new ImisValidationTable__c();
				string name = tableName + '_' + ivt.code;
				
				if(!sfValues.containsKey(name))
				{
					val.Name = name;
					val.Code__c = ivt.code;
					val.Description__c = ivt.Description;
					val.Table__c = tableName;
					
					newSfValues.add(val);
				}
				else if(sfValues.get(name).Description__c != ivt.description)
				{
					val = sfValues.get(name);
					val.Description__c = ivt.Description;
					
					newSfValues.add(val);
				}
			}
			
			if(!newSfValues.isEmpty())
			{
				upsert newSfValues;
			}
		}
	}
	
	public static List<ImisValidationTable> convertFromJson(string validationTable)
	{
		List<ImisValidationTable> values = new List<ImisValidationTable>();
		JSONParser parser = null;
            
        if(validationTable != null && validationTable != '')
        {
        	parser = JSON.createParser(validationTable);
	        
	        while (parser.nextToken() != null) 
	        {
	        	String fieldName = parser.getText();
	                
	            if(parser.getCurrentToken() == JSONToken.START_ARRAY)
	            {
	                while(parser.nextToken() != null)
	                {
	                    fieldName = parser.getText();
	                            
	                    if(parser.getCurrentToken() == JSONToken.START_OBJECT)
	                    {
	                       	ImisValidationTable vt = (ImisValidationTable)parser.readValueAs(ImisValidationTable.class);
	                       	values.add(vt);
	                    }
	                    else if(parser.getCurrentToken() == JSONToken.END_ARRAY)
	                    {
	                        break; 
	                    }
	                }
	            }
	        }
        }
        
        return values;
	}
}