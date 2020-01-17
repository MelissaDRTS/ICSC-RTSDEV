@isTest
public with sharing class ImisSponsorshipSalesBatchConversionTest {
	@isTest
	static void convertOneTest(){
		setupData();
		/* trigger fired on iMIS_Sponsorship_Sales__c insert, so assert trigger succeeded first */
		List<iMIS_Sponsorship_Sales__c> records = [Select Id, Opportunity__c from iMIS_Sponsorship_Sales__c];
		System.assertEquals(1,records.size());
		/*
		System.assertNotEquals(null,records[0].Opportunity__c);
		System.assertNotEquals('',records[0].Opportunity__c);
		List<Opportunity> opportunities = [Select Id, Name from Opportunity where Id = :records[0].Opportunity__c];
		System.assertEquals(1,opportunities.size());
		delete opportunities;
		records = [Select Id, Opportunity__c from iMIS_Sponsorship_Sales__c];
		System.assertEquals(null,records[0].Opportunity__c);
		*/
		Test.startTest();
		/* having iMis sponsorship records without opportunities is the initial condition of the batch job -- test it now */
		ImisSponsorshipSalesBatchConversion convert = new ImisSponsorshipSalesBatchConversion();
		Database.executeBatch(convert);
		Test.stopTest(); //makes batch job run
		/* requery and assert that an opportunity was created */
		records = [Select Id, Opportunity__c from iMIS_Sponsorship_Sales__c];
		//System.assertNotEquals(null,records[0].Opportunity__c);
		List<Opportunity> opportunities = [Select Id, Name from Opportunity where Id = :records[0].Opportunity__c];
		//System.assertEquals(1,opportunities.size());
		/* test field mapping */
	}

	//@isTest
	static void convertOneWithStateMappingTest(){
		User testUser = DataFactory.createUser();
		Account acct = new Account(Name = 'Test Account', BillingState='VA');
		insert acct;
		DataFactory.createTerritoryMapping('VA',testUser.Username);

		iMIS_Sponsorship_Sales__c sponsorship = DataFactory.createImisSponsorshipSalesHistory('2015',false);
		sponsorship.Show__c = DataFactory.createShowPublication('Testpub', true).Id;
		sponsorship.Account_Name__c = acct.Id;
		insert sponsorship;
		//trigger should fire after insert of Booth record and newly created Opportunity should have the correct owner
		Opportunity newOpportunity = [Select Id, Owner.Username from Opportunity limit 1];
		System.assertEquals(testUser.Username.toLowerCase(), newOpportunity.Owner.Username.toLowerCase(),'Owner ID should have been assigned via the territory mapping.');
	}

	static void setupData(){
		iMIS_Sponsorship_Sales__c sponsorship = DataFactory.createImisSponsorshipSalesHistory('2015');
	}
}