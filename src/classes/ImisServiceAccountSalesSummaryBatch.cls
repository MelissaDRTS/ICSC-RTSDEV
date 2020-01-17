global without sharing class ImisServiceAccountSalesSummaryBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
	public String query {get;set;}
    public String toEmail {get;set;}
    public String fromEmail {get;set;}
    public String error {get;set;}
    public String year {get;set;}
    private Boolean isTest {get;set;}
        
    global ImisServiceAccountSalesSummaryBatch(String query, boolean test)
    {
        ImisServiceConfiguration__c salesSummaryConfig = ImisServiceConfiguration__c.getvalues('Account Sales Summary Service');
        
        this.query = query;
        this.toEmail = salesSummaryConfig.AdminEmail__c;
        this.fromEmail = salesSummaryConfig.FromEmail__c;
        this.error = '';
        this.isTest = test;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext context, List<User> scope)
    {
        List<ID> userIds = new List<ID>();
            
        try
        {   
        	if(year == null || year == '')
        	{
            	ImisAccountSalesSummary.processDataFromImis();
        	}
        	else
        	{
        		ImisAccountSalesSummary.processDataFromImis(year);
        	}
        }
        catch(Exception ex)
        {
            this.error += ex.getMessage() + ' ' + ex.getStackTraceString() + ' ---- ';
        }
    }
    
    global void finish(Database.BatchableContext context)
    {
        try
        {
            if(this.isTest)
            {
                error += '*** Testing ***';
            }
            
            if(this.error != null && this.error != '')
            {
                System.debug(this.error);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(this.toEmail.split(','));
                mail.setReplyTo(this.fromEmail);
                mail.setSenderDisplayName('iMIS Account Sales Summary Batch');
               
                mail.setSubject('iMIS Account Sales Summary Batch Completed w/ Errors');
                mail.setPlainTextBody(error);
               
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            else
            {
                System.debug('iMIS Account Sales Summary Batch Completed Successfully');
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
}