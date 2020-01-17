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
private class TestAddProductWizardController 
{
	static testMethod void testAddProductWizard() 
    {
    	Account acct = DataFactory.createAccount('test', true);
        Opportunity opp = DataFactory.createOpp('test', acct.Id, DateTime.now().addDays(1), true);
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> clonedLineItems = new List<OpportunityLineItem>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsActive = true AND IsStandard = true LIMIT 1];
        List<Product2> products = new List<Product2>();
        Show_Publications__c show = DataFactory.createShowPublication(ShowPublicationUtility.getShowEventRecordTypeId(), 'Test Show', true);
        Show_Publications__c show2 = DataFactory.createShowPublication(ShowPublicationUtility.getShowEventRecordTypeId(), 'Test Show2', true);
        //ID standardPricebookId = Test.getStandardPricebookId();
                      
        products.add(DataFactory.createProduct('Test Prod 1', 'Advertising', false));
		products.add(DataFactory.createProduct('Test Prod 2', 'Booth', false));
		products.add(DataFactory.createProduct('Test Prod 3', 'Booth', false));
		 products.add(DataFactory.createProduct('Test Prod 4', 'Testxyz', false));
		insert products;
		
		pbes.add(DataFactory.createPricebookEntry(products[0].Id, standardPricebook.Id, 10, true));
		pbes.add(DataFactory.createPricebookEntry(products[1].Id, standardPricebook.Id, 20, true));
		pbes.add(DataFactory.createPricebookEntry(products[2].Id, standardPricebook.Id, 30, true));
		pbes.add(DataFactory.createPricebookEntry(products[3].Id, standardPricebook.Id, 30, true));
		//insert pbes;
		        
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
	        
	        controller.addProductsClick();
	        system.assertEquals(controller.ADD_PRODUCTS_STEP, controller.currentSection);
	        	        	        
	        List<SelectOption> fams = controller.getFamilies();
	        system.assert(fams.size() > 0);
	        
	        controller.selectedFamily = 'TestXyz';
	        controller.getProducts();
	        system.assertEquals(1, controller.lineItems.size());
	        
	        products[3].For_Packages_Only__c = true;
	        update products[3];
	        controller.lineItems = null;
	        
	        controller.selectedFamily = 'TestXyz';
	        controller.getProducts();
	        system.assertEquals(0, controller.lineItems.size());
	        controller.lineItems = null;
	        
	        controller.selectedFamily = 'Booth';
	        controller.getProducts();
	        system.assert(controller.lineItems.size() > 0);
	        
	        controller.continueClick();
	        system.assertEquals('You must select at least one product.', controller.message);
	        
	        controller.lineItems[0].selected = true;
	        controller.continueClick();
	        system.assertEquals('You must select a Show/Publication for each selected product.', controller.message);
	        
	        controller.lineItems[0].oli.Show_Event_Publication__c = show.Id;
	        controller.continueClick();
	        system.assertEquals(null, controller.message);
	        system.assertEquals(0, controller.selectedProducts.size());
	        system.assertEquals(1, controller.getCurrentlySelectedProducts().size());
	        system.assertEquals(controller.EDIT_INFO_STEP, controller.currentSection);
	       	
	       	//Clone product

	       	controller.selectedPricebookEntryId = controller.lineItems[0].oli.PricebookEntry.Id;
	       	controller.selectedItemNumber = controller.lineItems[0].itemNumber;
	       	controller.cloneProductClick();
	       	system.assertEquals(null, controller.message);
	        system.assertEquals(2, controller.getCurrentlySelectedProducts().size());
	        system.assertEquals(1, controller.clonedLineItems.size());
	       	
	        //Update show/publication
	        Show_Publications__c show3 = DataFactory.createShowPublication(ShowPublicationUtility.getShowEventRecordTypeId(), 'Test Show3', true);
	        show3.Show_Start_Date__c = Date.today().addDays(1);
	       	controller.lineItems[0].oli.Show_Event_Publication__c = show3.Id;
			controller.lineItems[0].oli.Discount = 0;
	       	controller.selectedPricebookEntryId = controller.lineItems[0].oli.PricebookEntry.Id;
	       	controller.selectedItemNumber = controller.lineItems[0].itemNumber;
	       	controller.updateShowPub();
	       	//system.assertEquals(controller.getCurrentlySelectedProducts()[1].oli.Insertion_Date__c, show3.Show_Start_Date__c);
	       	
	       	        
	        controller.saveAndAddProductsClick();
	        system.assertEquals(null, controller.message);
	        system.assertEquals(2, controller.selectedProducts.size());
	        system.assertEquals(3, controller.cartItemId);
	        system.assertEquals(controller.ADD_PRODUCTS_STEP, controller.currentSection);
	        
	        controller.selectedFamily = 'Advertising';
	        controller.getProducts();
	        system.assert(controller.lineItems.size() > 0);
	        
	        controller.lineItems[0].selected = true;
	        controller.lineItems[0].oli.Show_Event_Publication__c = show.Id;
	        controller.lineItems[0].oli.Discount = 0;
	        controller.continueClick();
	        controller.saveProductsClick();
	        system.assertEquals(null, controller.message);
	        system.assertEquals(3, controller.selectedProducts.size());
	        system.assertEquals(4, controller.cartItemId);
	        system.assertEquals(controller.OPTIONS_STEP, controller.currentSection);
	        
	        // Remove product
	        controller.selectedPricebookEntryId = controller.selectedProducts[1].oli.PricebookEntry.Id;
	       	controller.selectedItemNumber = controller.selectedProducts[1].itemNumber;
	       	controller.removeProductClick();
	       	system.assertEquals(2, controller.selectedProducts.size());
	        
	        
	        controller.addProductsClick();
	        system.assertEquals(controller.ADD_PRODUCTS_STEP, controller.currentSection);
	        
	        controller.backClick();
	        system.assertEquals(controller.OPTIONS_STEP, controller.currentSection);
	        
	        controller.editInfoBackClick();
	        system.assertEquals(controller.ADD_PRODUCTS_STEP, controller.currentSection);

	        controller.submitClick();
	        
	        List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem Where OpportunityId =: opp.Id];
        	
        Test.stopTest();
    }
    
    
   
}