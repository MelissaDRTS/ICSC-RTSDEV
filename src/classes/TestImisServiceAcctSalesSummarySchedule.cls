/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * BlackTab Group: Lynn Michels 1-21-15
 */
@isTest
private class TestImisServiceAcctSalesSummarySchedule {

    static testMethod void testSchedule()
    {
        String cron = '0 0 0 1 1 ? ' + Date.today().addYears(1).year();
    	String jobId = null;
        CronTrigger ct = null;
        ImisServiceAccountSalesSummarySchedule schedule = null;
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig('Account Sales Summary Service','http://64.14.178.228/v1.6/blacktab/summary/', null, null, 1);
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse());
              
	        schedule = new ImisServiceAccountSalesSummarySchedule();
	        schedule.isTest = true;
	        jobId = System.schedule('Imis Service Account Sales Summary Schedule Test', cron, schedule);
	                
			ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	       	
	       	System.assertEquals(0, ct.TimesTriggered);
	       	
	       	System.assertEquals(Date.today().addYears(1).year() + '-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}