global with sharing class CloseOldOpportunitiesBatch implements Database.Batchable<SObject>
{
    public String query {get;set;}
        
    global CloseOldOpportunitiesBatch(String query)
    {
    	this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> scope)
    {
        try
        {   
            for(Opportunity opp : scope)
            {
            	opp.StageName = 'Closed Lost';
            }
            
            update scope;
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext context)
    {
        
    }
}