global without sharing class ImisServiceAccountProcessorBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
    public String query {get;set;}
    public String toEmail {get; set;}
    public String fromEmail {get; set;}
    public String error {get;set;}
    public List<String> logLines {get;set;}
    private Boolean jobCompleted{get;set;}
    private Boolean isTest{get;set;}
        
    global ImisServiceAccountProcessorBatch(String query, boolean test)
    {
        ImisServiceConfiguration__c accountConfig = ImisServiceConfiguration__c.getvalues('Account Service');
        this.logLines = new List<String>();
        this.query = query;
        this.toEmail = accountConfig.AdminEmail__c;
        this.fromEmail = accountConfig.FromEmail__c;
        this.error = '';
        this.jobCompleted = false;
        this.isTest = test;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext context, List<User> scope)
    {
        List<ID> userIds = new List<ID>();
        /*if(jobCompleted == true){
            return;
        } */           
        try
        {   
            ImisAccount.processLatestUpdatesFromImis();
        	ImisServiceConfiguration__c accountConfig = ImisServiceConfiguration__c.getvalues('Account Service');
            /*if(accountConfig.StartingRow__c == 1){
                jobCompleted = true;
            }*/
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
            if(this.error != null && this.error != '')
            {
                System.debug(this.error);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(this.toEmail.split(','));
                mail.setReplyTo(this.fromEmail);
                mail.setSenderDisplayName('iMIS Account Batch');
               
                mail.setSubject('iMIS Account Batch Completed w/ Errors');
                mail.setPlainTextBody(error);
               
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            else
            {
                System.debug('iMIS Account Batch Completed Successfully');
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
        }
        
        try
        {
        	//Schedule batch to run again if it's not a test (runs every minute)
            if(isTest==null || !isTest)
            {
                System.debug('Scheduling new run...');
            	String cronId = System.scheduleBatch(new ImisServiceAccountProcessorBatch('Select ID from User LIMIT 10', false), 'Account Service', 120);
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
}