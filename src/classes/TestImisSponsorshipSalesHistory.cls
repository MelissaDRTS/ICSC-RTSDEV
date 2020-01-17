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
private class TestImisSponsorshipSalesHistory {

    static testMethod void TestImisSponsorshipSalesHistory() {
       ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig
        	('Sponsorship Sales History Service', 'http://64.14.178.228/v1.6/blacktab/sponsorship/', null, null, null);
        List<iMIS_Sponsorship_Sales__c> sponsorshipSalesSummary = null;
        List<Account> accounts = new List<Account>();
        		accounts.add(new Account(Name='TestAccount1',
        								iMIS_ID__c='1548889'));
        		accounts.add(new Account(Name='TestAccount2',
        								iMIS_ID__c='1568686'));
        		accounts.add(new Account(Name='TestAccount3',
        								iMIS_ID__c='1570303'));
        		accounts.add(new Account(Name='TestAccount4',
        								iMIS_ID__c='1571567'));
        		
        	insert accounts;
       List<Show_Publications__c> showPubs = new List<Show_Publications__c>(); 	
       		showPubs.add(new Show_Publications__c(Name ='TestShow',
       									iMIS_Meeting_Code_Sponsorship__c = '2013CAS'));
       		showPubs.add(new Show_Publications__c(Name ='TestShow2',
       									iMIS_Meeting_Code_Sponsorship__c = '2013CCS'));
       		showPubs.add(new Show_Publications__c(Name ='TestShow3',
       									iMIS_Meeting_Code_Sponsorship__c = '2013S45S'));
       		showPubs.add(new Show_Publications__c(Name ='TestShow4',
       									iMIS_Meeting_Code_Sponsorship__c = '2013N90S'));
       		showPubs.add(new Show_Publications__c(Name ='TestShow5',
       									iMIS_Meeting_Code_Sponsorship__c = '2013APCS'));
       	insert showPubs;
        	
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse()); 
        	
	       	sponsorshipSalesSummary = [SELECT Id FROM iMIS_Sponsorship_Sales__c];
        	system.assertEquals(0, sponsorshipSalesSummary.size());
        	
        	ImisSponsorshipSalesHistory.processDataFromImis();
        	
        	sponsorshipSalesSummary = [SELECT Id FROM iMIS_Sponsorship_Sales__c];
        	system.assertEquals(5, sponsorshipSalesSummary.size());
        Test.stopTest();	
    }
}