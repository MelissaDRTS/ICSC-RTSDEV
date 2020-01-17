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
@isTest(seealldata=true)
private class TestAddProductWizardController2 
{

   	static testMethod void testAddPackageWizard() 
    {
    	Account acct = DataFactory.createAccount('test2', true);
        Opportunity opp = DataFactory.createOpp('test2', acct.Id, DateTime.now().addDays(1), true);
        Show_Publications__c showPub = null;
        List<Sponsorship_Package__c> sponsorPackages = new List<Sponsorship_Package__c>();
        List<Opportunity_Package__c> ops = new List<Opportunity_Package__c>();
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<Package_Line_Item__c> plis = new List<Package_Line_Item__c>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsActive = true AND IsStandard = true LIMIT 1];
        List<Product2> products = new List<Product2>();
       // ID standardPricebookId = Test.getStandardPricebookId();
        
        showPub = DataFactory.createShowPublication(DataFactory.SHOW_PUBLICATION_PUBLICATION_TYPE_ID, 'Test Show2', false);
        showPub.Show_Start_Date__c = Date.today();
        showPub.Show_End_Date__c = Date.today().addDays(1);
        insert showpub;
        
        sponsorPackages.add(DataFactory.createSponsorshipPackage(showPub.Id, 'Gold2', false));    
        insert sponsorPackages;
                        
        products.add(DataFactory.createProduct('Test Prod 12', 'Advertising', false));
		products.add(DataFactory.createProduct('Test Prod 22', 'Sponsorship', false));
		products.add(DataFactory.createProduct('Test Prod 32', 'Booth', false));
		
		insert products;
		pbes.add(DataFactory.createPricebookEntry(products[0].Id, standardPricebook.Id, 10,  true));
		pbes.add(DataFactory.createPricebookEntry(products[1].Id, standardPricebook.Id, 20, true));
		pbes.add(DataFactory.createPricebookEntry(products[2].Id, standardPricebook.Id, 30, true));
		//insert pbes;

		plis.add(DataFactory.createPackageLineItem(sponsorPackages[0].id, products[0].Id, 20, 1, false));
		insert plis;
        
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[0].Id, 10, 1, false));
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[1].Id, 10, 1, false));
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[2].Id, 10, 1, false));
        insert lineItems;
        
        Test.startTest();
	        AddProductWizardController controller = null;
	        controller = new AddProductWizardController();
	        
	        system.assertEquals('Invalid opportunity ID.', controller.message);
	        
	        PageReference pageRef = Page.AddProductWizard;
        	ApexPages.currentPage().getParameters().put('id', opp.Id);  
        	    
	        controller = new AddProductWizardController();	        
	        system.assertEquals(null, controller.message);
	        system.assertEquals(controller.OPTIONS_STEP, controller.currentSection);
	        
	        controller.addPackagesClick();
	        system.assertEquals(controller.ADD_PACKAGE_STEP, controller.currentSection);
	        	        	        
	        List<SelectOption> sps = controller.getShows();
	        system.assert(sps.size() > 0);
	        
	        controller.selectedShow = showPub.Id;
	        controller.getPackageList();
	        system.assertEquals(1, controller.packages.size());
	        
	        controller.saveAndAddPackagesClick();
	        system.assertEquals('You must select at least one package.', controller.message);
	        
	        controller.packages[0].selected = true;
	        controller.saveAndAddPackagesClick();
	        system.assertEquals(null, controller.message);
	        system.assertEquals(1, controller.selectedPackages.size());
	        system.assertEquals(2, controller.cartItemId);
	        system.assertEquals(controller.ADD_PACKAGE_STEP, controller.currentSection);
	        
	        controller.selectedShow = showPub.Id;
	        controller.getPackageList();
	        system.assertEquals(1, controller.packages.size());
	        
	        controller.savePackagesClick();
	        system.assertEquals('You must select at least one package.', controller.message);
	        
	        controller.packages[0].selected = true;
	        controller.savePackagesClick();
	        system.assertEquals(null, controller.message);
	        system.assertEquals(2, controller.selectedPackages.size());
	        system.assertEquals(3, controller.cartItemId);
	        system.assertEquals(controller.OPTIONS_STEP, controller.currentSection);
	        
	        controller.addPackagesClick();
	        system.assertEquals(controller.ADD_PACKAGE_STEP, controller.currentSection);
	        
	        controller.backClick();
	        system.assertEquals(controller.OPTIONS_STEP, controller.currentSection);
	        
	        controller.submitClick();
	        
	        ops = [SELECT Id FROM Opportunity_Package__c Where Sponsorship_Package__c =: sponsorPackages[0].Id And Opportunity__c =: opp.Id];
	        system.assertEquals(2, ops.size());
	        lineItems = [SELECT Id, Description, Opportunity_Package__c FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        	
			for(OpportunityLineItem oli : lineItems)
			{
				if(oli.Opportunity_Package__c != null)
				{
					System.assertEquals('Test', oli.Description);
				}
			}
        	
        Test.stopTest();
    }
}