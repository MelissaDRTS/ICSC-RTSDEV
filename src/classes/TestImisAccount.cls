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
private class TestImisAccount 
{

    static testMethod void verifyGetAccountCallout() 
    {
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig('Account Service', 'http://64.14.178.228/v1.6/accounts/', null, 5, 0);
        List<Account> accounts = null;
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse()); 
        	System.assertEquals(null, accountConfig.LastModified__c);
        	System.assertEquals(0, accountConfig.StartingRow__c);
        	
	       	accounts = [SELECT Id FROM Account];
        	system.assertEquals(0, accounts.size());
        	
        	ImisAccount.processLatestUpdatesFromImis();
        	
        	accounts = [SELECT Id FROM Account];
        	system.assertEquals(5, accounts.size());
        	
        	accountConfig = ImisServiceConfiguration__c.getvalues('Account Service');
        	System.assertEquals(null, accountConfig.LastModified__c);
        	System.assertEquals(5, accountConfig.StartingRow__c);
        	        	
        Test.stopTest();
    }
    
    static testMethod void verifyGetAccountCallout2() 
    {
    	DateTime lastModified = DateTime.now().addMinutes(-10);
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig('Account Service', 'http://64.14.178.228/v1.6/accounts/', lastModified, 10, 5);
        List<Account> accounts = null;
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse());
        	System.assertEquals(lastModified, accountConfig.LastModified__c);
        	System.assertEquals(5, accountConfig.StartingRow__c);
        	
	       	accounts = [SELECT Id FROM Account];
        	system.assertEquals(0, accounts.size());
        	
        	ImisAccount.processLatestUpdatesFromImis();
        	
        	accounts = [SELECT Id FROM Account];
        	system.assertEquals(5, accounts.size());
        	
        	accountConfig = ImisServiceConfiguration__c.getvalues('Account Service');
        	System.assert(lastModified < accountConfig.LastModified__c);
        	System.assertEquals(1, accountConfig.StartingRow__c);
        	        	
        Test.stopTest();
    }
}