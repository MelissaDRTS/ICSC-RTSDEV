global with sharing class ImisServiceBoothSalesBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
    public String query {get;set;}
    public String toEmail {get;set;}
    public String fromEmail {get; set;}
    public String error {get;set;}
    public String year{get;set;}
    public List<String> logLines{get;set;}
    public Boolean jobCompleted{get;set;}
    private Boolean isTest{get;set;}
        
    global ImisServiceBoothSalesBatch(String query, boolean test)
    {
        ImisServiceConfiguration__c boothHistoryConfig = ImisServiceConfiguration__c.getvalues('Booth Sales History Service');
        
        this.query = query;
        this.toEmail = boothHistoryConfig.AdminEmail__c;
        this.fromEmail = boothHistoryConfig.FromEmail__c;
        this.error = '';
        this.isTest = test;
        this.logLines = new List<String>();
        jobCompleted = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext context, List<User> scope)
    {
        List<ID> userIds = new List<ID>();
        if(jobCompleted == true)
            return;    
        try
        {   
            
            if(year == null || year == '')
            {
                logLines.addAll(ImisBoothSalesHistory.processDataFromImis());
            }
            else
            {
                logLines.addAll(ImisBoothSalesHistory.processDataFromImis(year));
            }
            ImisServiceConfiguration__c boothHistoryConfig = ImisServiceConfiguration__c.getvalues('Booth Sales History Service');
            if(boothHistoryConfig.StartingRow__c == 1){
                //if the job has run at least once, and the starting row has been reset to 1, we are done.
                jobCompleted = true;
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
            if(this.isTest != null && this.isTest == true)
            {
                error = '*** Testing ***\r\n' + error;
            }
            
            if(this.error != null && this.error != '')
            {
                System.debug(this.error);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(this.toEmail.split(','));
                mail.setReplyTo(fromEmail);
                mail.setSenderDisplayName('iMIS Booth Sales Batch');
               
                mail.setSubject('iMIS Booth Sales Batch Completed w/ Errors');
                if(logLines!=null)
                    error += '*** Config: '+ImisServiceConfiguration__c.getvalues('Booth Sales History Service') + '\r\n' + String.join(logLines, '\r\n');
                else
                error += '*** Config: '+ImisServiceConfiguration__c.getvalues('Booth Sales History Service');
                mail.setPlainTextBody(error);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            else if(logLines != null && logLines.size() > 0){
                System.debug('iMIS Booth Sales Batch Completed Successfully');
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(this.toEmail.split(','));
                mail.setReplyTo(fromEmail);
                mail.setSenderDisplayName('iMIS Booth Sales Batch');
               
                mail.setSubject('iMIS Booth Sales Batch Completed Successfully');
                mail.setPlainTextBody(String.join(logLines,'\r\n'));
                String column = 'Message \n';
                boolean attach = false;
                for(String s : logLines){
                    if(s.contains('WARNING')){
                        column += s + '\n';
                        attach = true;
                    }
                }
                if(attach == true){
                    Messaging.EmailFileAttachment csv = new Messaging.EmailFileAttachment();
                    blob csvBlob = Blob.valueOf(column);
                    string csvName = 'WarningLog.csv';
                    csv.setFileName(csvName);
                    csv.setBody(csvBlob);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csv});
                    ImisServiceConfiguration__c boothHistoryConfig = ImisServiceConfiguration__c.getvalues('Booth Sales History Service');
                    if(boothHistoryConfig.WarningEmailList__c != null){
                        Messaging.SingleEmailMessage warningMail = new Messaging.SingleEmailMessage();
                        warningMail.setToAddresses(boothHistoryConfig.WarningEmailList__c.split(','));
                        warningMail.setReplyTo(fromEmail);
                        warningMail.setSenderDisplayName('iMIS Booth Sales Batch');
                        warningMail.setSubject('iMIS Booth Sales Batch Completed Successfully');
                        warningMail.setPlainTextBody(column);
                        warningMail.setFileAttachments(new Messaging.EmailFileAttachment[]{csv});
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{warningMail});
                    }
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                   System.debug('iMIS Booth Sales Batch Completed Successfully');
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(this.toEmail.split(','));
            mail.setReplyTo(fromEmail);
            mail.setSenderDisplayName('iMIS Booth Sales Batch');
            
            mail.setSubject('iMIS Booth Sales Batch Failed');
            mail.setPlainTextBody(ex.getMessage() + ' ' + ex.getStackTraceString());
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }
}