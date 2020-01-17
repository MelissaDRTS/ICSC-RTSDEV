global with sharing class ImisServiceSponsorshipSalesBatch  implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
	public String query {get;set;}
    public String toEmail {get; set;}
    public String fromEmail {get; set;}
    public String error {get;set;}
    public String year{get;set;}
    private Boolean isTest{get;set;}
    private Boolean jobCompleted{get;set;}
    public List<String> logLines{get;set;}
        
    global ImisServiceSponsorshipSalesBatch(String query, boolean test)
    {
        ImisServiceConfiguration__c sponsorshipHistoryConfig = ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service');
        
        this.query = query;
        this.toEmail = sponsorshipHistoryConfig.AdminEmail__c;
        this.fromEmail = sponsorshipHistoryConfig.FromEmail__c;
        this.error = '';
        this.logLines = new List<String>();

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
        if(jobCompleted){
            return;
        }    
        try
        {               
            if(year == null || year == '')
        	{
            	logLines.addAll(ImisSponsorshipSalesHistory.processDataFromImis());
        	}
        	else
        	{
        		logLines.addAll(ImisSponsorshipSalesHistory.processDataFromImis(year));
        	}
        }
        catch(Exception ex)
        {
            this.error += ex.getMessage() + ' ' + ex.getStackTraceString() + ' ---- ';
        }
        ImisServiceConfiguration__c sponsorshipHistoryConfig = ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service');

        if(sponsorshipHistoryConfig.StartingRow__c == 1){
            jobCompleted = true;
        }
    }
    
    global void finish(Database.BatchableContext context)
    {
        try
        {
            if(this.isTest != null && this.isTest == true)
            {
                error += '*** Testing ***';
            }
            
            if(this.error != null && this.error != '')
            {
                System.debug(this.error);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(this.toEmail.split(','));
                mail.setReplyTo(fromEmail);
                mail.setSenderDisplayName('iMIS Sponsorship Sales Batch');
               
                mail.setSubject('iMIS Sponsorship Sales Batch Completed w/ Errors');
                error += 'Configuration: ' + ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service');
                if(logLines!=null && logLines.size() > 0){
                    error += '\r\n' + String.join(logLines, '\r\n');
                }
                mail.setPlainTextBody(error);
               
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            else if(logLines != null && logLines.size() > 0){
                System.debug('iMIS Sponsorship Sales Batch Completed Successfully with warnings');
                logLines.add('Configuration: ' + ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service'));
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(this.toEmail.split(','));
                mail.setReplyTo(fromEmail);
                mail.setSenderDisplayName('iMIS Sponsorship Sales Batch');
               
                mail.setSubject('iMIS Sponsorship Sales Batch Completed Successfully w/ Warnings');
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
                    Messaging.SingleEmailMessage warningMail = new Messaging.SingleEmailMessage();
                    if(boothHistoryConfig.WarningEmailList__c != null){
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
            }
            else
            {
                System.debug('iMIS Sponsorship Sales Batch Completed Successfully');
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            if(logLines == null)
                logLines = new List<String>();
            logLines.add('Configuration: ' + ImisServiceConfiguration__c.getvalues('Sponsorship Sales History Service'));
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(this.toEmail.split(','));
            mail.setReplyTo(fromEmail);
            mail.setSenderDisplayName('iMIS Sponsorship Sales Batch');
            
            mail.setSubject('iMIS Sponsorship Sales Batch Failed');
            mail.setPlainTextBody(ex.getMessage() + ' ' + ex.getStackTraceString() + '\r\n' + String.join(logLines,'\r\n'));
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }
}