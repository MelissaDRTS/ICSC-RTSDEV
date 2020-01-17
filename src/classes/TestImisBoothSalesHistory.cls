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
private class TestImisBoothSalesHistory {

    static testMethod void TestImisBoothSalesHistory() {
       
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig
        	('Booth Sales History Service', 'http://64.14.178.228/v1.6/blacktab/booth/', null, null, null);
        List<iMIS_Booth__c> boothSalesSummary = null;
        List<Account> accounts = new List<Account>();
        		accounts.add(new Account(Name='TestAccount1',
        								iMIS_ID__c='1025154'));
        		accounts.add(new Account(Name='TestAccount2',
        								iMIS_ID__c='1009474'));
        		accounts.add(new Account(Name='TestAccount3',
        								iMIS_ID__c='1002319'));
        		accounts.add(new Account(Name='TestAccount4',
        								iMIS_ID__c='1034192'));
        		accounts.add(new Account(Name='TestAccount5',
        								iMIS_ID__c='1006188'));
        		accounts.add(new Account(Name='TestAccount6',
        								iMIS_ID__c='1001697'));
        		accounts.add(new Account(Name='TestAccount7',
        								iMIS_ID__c='1051384'));
        		accounts.add(new Account(Name='TestAccount8',
        								iMIS_ID__c='1056951'));
        		accounts.add(new Account(Name='TestAccount9',
        								iMIS_ID__c='1003844'));
        	insert accounts;
       Show_Publications__c showPub = new Show_Publications__c(Name ='TestShow',
       									iMIS_Meeting_Code_Booth__c = 'WS2014');
       	insert showPub;
        	
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse()); 
        	
	       	boothSalesSummary = [SELECT Id FROM iMIS_Booth__c];
        	system.assertEquals(0, boothSalesSummary.size());
        	
        	ImisBoothSalesHistory.processDataFromImis();
        	
        	boothSalesSummary = [SELECT Id FROM iMIS_Booth__c];
        	system.assertEquals(9, boothSalesSummary.size());
        Test.stopTest();	
    }
}