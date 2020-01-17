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
private class TestImisValidationTable 
{
    static testMethod void testImport() 
    {
        Map<String, ImisValidationTable__c> sfValues = ImisValidationTable__c.getAll();
        ImisValidationTable__c adv = null;
        
        System.assert(sfValues.isEmpty());
        	
    	adv = new ImisValidationTable__c(Name = 'primary_ADV', Code__c = 'ADV', Description__c = 'Test', Table__c = 'primary');
    	insert adv;
    	
    	sfValues = ImisValidationTable__c.getAll();
    	System.assert(!sfValues.isEmpty());
        	
        Test.startTest();
        	        	
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse());
        	
        	ImisValidationTable.importValues('primary', 'http://64.14.178.228/v1.6/validationtables/primary', '');
        	
        	sfValues = ImisValidationTable__c.getAll();
        	System.assertEquals(5, sfValues.size());
        	
        Test.stopTest();
        
    }
}