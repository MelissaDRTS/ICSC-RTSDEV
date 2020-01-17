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
@isTest(SeeAllData = true)
private class TestOpportunityLineItemTrigger 
{
	static testMethod void testOppPackageDelete() 
    {
        Account acct = DataFactory.createAccount('Test Account', true);
        List<Opportunity> opps = new List<Opportunity>();
        Show_Publications__c showPub = null;
        List<Sponsorship_Package__c> sponsorPackages = new List<Sponsorship_Package__c>();
        List<Opportunity_Package__c> ops = new List<Opportunity_Package__c>();
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsActive = true AND IsStandard = true LIMIT 1];
        List<Product2> products = new List<Product2>();
        //ID standardPricebookId = Test.getStandardPricebookId();
                      
        products.add(DataFactory.createProduct('Test Prod 1', 'Advertising', false));
		products.add(DataFactory.createProduct('Test Prod 2', 'Booth', false));
		insert products;
		
		pbes.add(DataFactory.createPricebookEntry(products[0].Id, standardPricebook.Id, 10, true));
		pbes.add(DataFactory.createPricebookEntry(products[1].Id, standardPricebook.Id, 20, true));
		//insert pbes;
		        
        showPub = DataFactory.createShowPublication(DataFactory.SHOW_PUBLICATION_PUBLICATION_TYPE_ID, 'Test Show', true);
        sponsorPackages.add(DataFactory.createSponsorshipPackage(showPub.Id, 'Gold', false));    
        insert sponsorPackages;    
        
        opps.add(DataFactory.createOpp('Test opp 1', acct.Id, System.now().addDays(2), false));
        insert opps;
        
        Test.startTest();
            ops.add(DataFactory.createOpportunityPackage(sponsorPackages[0].Id, opps[0].Id, 1, false));
	        insert ops;
	        	        
	        lineItems.add(DataFactory.createOpportunityLineItem(opps[0].Id, pbes[0].Id, 10, 1, false));
        	lineItems.add(DataFactory.createOpportunityLineItem(opps[0].Id, pbes[1].Id, 10, 1, false));
        	lineItems[0].Opportunity_Package__c = ops[0].Id;
        	lineItems[1].Opportunity_Package__c = ops[0].Id;
        	insert lineItems;
        	
	        ops = [SELECT Id FROM Opportunity_Package__c WHERE Id =: ops[0].Id];
	        System.assert(ops.size() == 1);
	        
	        delete lineItems[0];
	        ops = [SELECT Id FROM Opportunity_Package__c WHERE Id =: ops[0].Id];
	        System.assert(ops.size() == 1);
	        
	        delete lineItems[1];
	        ops = [SELECT Id FROM Opportunity_Package__c WHERE Id =: ops[0].Id];
	        System.assert(ops.size() == 0);
	        
        Test.stopTest();
    }
    
    static testMethod void testShowRollUpTotals() 
    {
    	List<Account> accountList = new List<Account>();  
    	List<Opportunity> oppList = new List<Opportunity>();	
    	List<Show_Publications__c> showList = new List<Show_Publications__c>();
    	List<Pricebook2> standardPricebook = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true AND IsStandard = true];
		List<Product2> products = new List<Product2>();						//create a list of products
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();	
		List<Show_Publications__c>  showResultsList = null;
    	
    	//create account
    	accountList.add(new Account(Name = 'TestAccount'));
   		insert accountList;
   		
   		//two opportunities attached to the same account
    	oppList.add(new Opportunity(Name = 'FirstTestOpp',
    								AccountId = accountList[0].Id,
    								CloseDate = System.today(),
									StageName = 'In Discussions'));
		oppList.add(new Opportunity(Name = 'SecondTestOpp',
    								AccountId = accountList[0].Id,
    								CloseDate = System.today(),
									StageName = 'Closed Won'));							
 		insert oppList;
 		
 		//create a show/publication
 		showList.add(new Show_Publications__c(Name = 'ShowTest',
 											Show_Start_Date__c= System.today(),
 											Show_End_Date__c = System.today().addYears(2)));
 		insert showList;									
 		
 		//create a product   								
		products.add(new Product2(Name = 'ProductTest',
								Family = 'Advertising',
								ProductCode = 'T123'));
		insert products;	
		
		//add the price to the product via PricebookEntry
		PricebookEntry pbe = null;
		pbe = new PricebookEntry(	Product2Id = products[0].Id,
	  								UnitPrice = 100,
									Pricebook2Id = standardPricebook[0].Id,
									IsActive = true);	
		insert pbe;	
		
		//add the product to an opportunity creating opportunityLineItem
		oliList.add(new OpportunityLineItem(	OpportunityId = oppList[0].Id,
										Quantity = 2,                  
										UnitPrice = pbe.UnitPrice, 
										PricebookEntryId = pbe.Id,
										Show_Event_Publication__c = showList[0].Id));	
		oliList.add(new OpportunityLineItem(	OpportunityId = oppList[1].Id,
										Quantity = 1,                  
										UnitPrice = pbe.UnitPrice, 
										PricebookEntryId = pbe.Id,
										Show_Event_Publication__c = showList[0].Id));									
		insert oliList;	
		
		//test the inserts
		showResultsList = 	[	SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
								FROM Show_Publications__c
								WHERE Id =: showList[0].Id];
		System.assertEquals(200,showResultsList[0].Total_Opps_in_Pipeline__c);
		System.assertEquals(100,showResultsList[0].Total_Won_Opps__c);
		
		//test update
		oliList[0].UnitPrice = 1000;
		oliList[1].UnitPrice = 150;
		update oliList;	
		showResultsList = 	[	SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
								FROM Show_Publications__c
								WHERE Id =: showList[0].Id];
		System.assertEquals(2000,showResultsList[0].Total_Opps_in_Pipeline__c);
		System.assertEquals(150,showResultsList[0].Total_Won_Opps__c);
									
		delete oliList[1];
		showResultsList = 	[	SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
								FROM Show_Publications__c
								WHERE Id =: showList[0].Id];
		System.assertEquals(2000,showResultsList[0].Total_Opps_in_Pipeline__c);
		System.assertEquals(0,showResultsList[0].Total_Won_Opps__c);
		
		delete oliList[0];
		showResultsList = 	[	SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
								FROM Show_Publications__c
								WHERE Id =: showList[0].Id];
		System.assertEquals(0,showResultsList[0].Total_Opps_in_Pipeline__c);
		System.assertEquals(0,showResultsList[0].Total_Won_Opps__c);
		
    }
}