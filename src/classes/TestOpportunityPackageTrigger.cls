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
private class TestOpportunityPackageTrigger 
{
    static testMethod void testPendingSoldRollUp() 
    {
    	Account acct = DataFactory.createAccount('Test Account', true);
        List<Opportunity> opps = new List<Opportunity>();
        Show_Publications__c showPub = null;
        List<Sponsorship_Package__c> sponsorPackages = new List<Sponsorship_Package__c>();
        List<Opportunity_Package__c> ops = new List<Opportunity_Package__c>();
        
        showPub = DataFactory.createShowPublication(DataFactory.SHOW_PUBLICATION_PUBLICATION_TYPE_ID, 'Test Show', true);
        sponsorPackages.add(DataFactory.createSponsorshipPackage(showPub.Id, 'Gold', false));    
        insert sponsorPackages;    
        
        opps.add(DataFactory.createOpp('Test opp 1', acct.Id, System.now().addDays(2), false));
        opps.add(DataFactory.createOpp('Test opp 2', acct.Id, System.now().addDays(4), false));
        insert opps;
        
        Test.startTest();
        	sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
        	System.assertEquals(0, sponsorPackages[0].Units_Sold__c, sponsorPackages[0].Units_Pending__c);
        	
            ops.add(DataFactory.createOpportunityPackage(sponsorPackages[0].Id, opps[0].Id, 2, false));
	        ops.add(DataFactory.createOpportunityPackage(sponsorPackages[0].Id, opps[1].Id, 1, false));
	        insert ops;
	        
	        sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
	        System.assertEquals(0, sponsorPackages[0].Units_Sold__c);
	        System.assertEquals(3, sponsorPackages[0].Units_Pending__c);
	        
	        opps.add(DataFactory.createOpp('Test opp 1', acct.Id, System.now().addDays(2), false));
	       	opps[2].StageName = 'Closed Won';
	       	insert opps[2];
	       	
	       	ops.add(DataFactory.createOpportunityPackage(sponsorPackages[0].Id, opps[2].Id, 1, false));
	       	insert ops[2];
	        
	        sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
	        System.assertEquals(1, sponsorPackages[0].Units_Sold__c);
	        System.assertEquals(3, sponsorPackages[0].Units_Pending__c);
	        
	        delete ops[1];
	        sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
	        System.assertEquals(1, sponsorPackages[0].Units_Sold__c);
	        System.assertEquals(2, sponsorPackages[0].Units_Pending__c);
	        
	        undelete ops[1];
	        sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
	        System.assertEquals(1, sponsorPackages[0].Units_Sold__c);
	        System.assertEquals(3, sponsorPackages[0].Units_Pending__c);
	        
	         delete ops;
	        sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
	        System.assertEquals(0, sponsorPackages[0].Units_Sold__c);
	        System.assertEquals(0, sponsorPackages[0].Units_Pending__c);
        Test.stopTest();
    }
}