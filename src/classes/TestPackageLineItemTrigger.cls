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
private class TestPackageLineItemTrigger 
{
	private static testMethod void testListPriceLookup()
	{
		List<Pricebook2> standardPricebooks = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true AND IsStandard = true];
		List<Product2> prods = new List<Product2>();
		List<PricebookEntry> pbes = new List<PricebookEntry>();
		Sponsorship_Package__c sponsorshipPackage = null;
		Package_Line_Item__c pli = null;
		Show_Publications__c show = null;
		
		prods.add(DataFactory.createProduct('Prod 2', '', false));
		prods.add(DataFactory.createProduct('Prod 2', '', false));
		insert prods;
		
		pbes.add(new PricebookEntry(Product2Id = prods[0].Id, UnitPrice = 50, Pricebook2Id = standardPricebooks[0].Id, IsActive = true));
		pbes.add(new PricebookEntry(Product2Id = prods[1].Id, UnitPrice = 75, Pricebook2Id = standardPricebooks[0].Id, IsActive = true));
		insert pbes;
		
		show = new Show_Publications__c(Name = 'Show');
		insert show;
		
		sponsorshipPackage = new Sponsorship_Package__c(Name = 'Gold', Show_Publication__c = show.Id);
		insert sponsorshipPackage;
		
		pli = new Package_Line_Item__c(Sponsorship_Package__c = sponsorshipPackage.Id, Product__c = prods[0].Id, Sales_Price__c = 40, Quantity__c = 1);
		insert pli;
		
		Test.startTest();
		
			pli = [SELECT Id, List_Price__c FROM Package_Line_Item__c WHERE Id =: pli.Id];
			System.assertEquals(50, pli.List_Price__c);
			
			pli.Product__c = prods[1].Id;
			update pli;
			
			pli = [SELECT Id, List_Price__c FROM Package_Line_Item__c WHERE Id =: pli.Id];
			System.assertEquals(75, pli.List_Price__c);
			
			pli.Product__c = null;
			update pli;
			
			pli = [SELECT Id, List_Price__c FROM Package_Line_Item__c WHERE Id =: pli.Id];
			System.assertEquals(0, pli.List_Price__c);
		
		Test.stopTest();
	}
}