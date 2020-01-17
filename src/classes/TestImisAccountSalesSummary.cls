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
 */
@isTest
private class TestImisAccountSalesSummary {

    static testMethod void verifyAccountSalesSummary() {
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig
        	('Account Sales Summary Service', 'http://64.14.178.228/v1.6/blacktab/summary/', null, null, null);
        List<Account_Sales_Summary__c> accountSalesSummary = null;
        List<Account> accounts = new List<Account>();
        		accounts.add(new Account(Name='TestAccount1',
        								iMIS_ID__c='1568686'));
        		accounts.add(new Account(Name='TestAccount2',
        								iMIS_ID__c='1570303'));
        		accounts.add(new Account(Name='TestAccount3',
        								iMIS_ID__c='1571567'));
        		accounts.add(new Account(Name='TestAccount4',
        								iMIS_ID__c='1572878'));
        		accounts.add(new Account(Name='TestAccount5',
        								iMIS_ID__c='1579368'));
        	insert accounts;
        	
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse()); 
        	
	       	accountSalesSummary = [SELECT Id FROM Account_Sales_Summary__c];
        	system.assertEquals(0, accountSalesSummary.size());
        	
        	ImisAccountSalesSummary.processDataFromImis();
        	
        	accountSalesSummary = [SELECT Id FROM Account_Sales_Summary__c];
        	system.assertEquals(5, accountSalesSummary.size());
        Test.stopTest();	
    }
}