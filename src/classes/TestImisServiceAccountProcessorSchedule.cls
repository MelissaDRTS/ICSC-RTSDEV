@isTest
private class TestImisServiceAccountProcessorSchedule 
{
    static testMethod void testSchedule() 
    {
    	String cron = '0 0 0 1 1 ? ' + Date.today().addYears(1).year();
    	String jobId = null;
        CronTrigger ct = null;
        ImisServiceAccountProcessorBatchSchedule schedule = null;
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig('Account Service','http://64.14.178.228/v1.6/accounts/', null, 5, 0);
        List<Account> accounts = null;
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse());
              
	        schedule = new ImisServiceAccountProcessorBatchSchedule();
	        schedule.isTest = true;
	        jobId = System.schedule('Imis Service Account Processor Batch Schedule Test', cron, schedule);
	                
			ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	       	
	       	System.assertEquals(0, ct.TimesTriggered);
	       	
	       	System.assertEquals(Date.today().addYears(1).year() + '-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}