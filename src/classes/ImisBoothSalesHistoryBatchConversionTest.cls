@isTest
private class ImisBoothSalesHistoryBatchConversionTest
{
	@isTest
	static void convertOneTest(){
		setupData();
		/* trigger fired on iMis_Booth__c insert, so assert trigger succeeded first */
		/*
		List<iMis_Booth__c> records = [Select Id, Opportunity__c from iMis_Booth__c];
		System.assertEquals(1,records.size());
		System.assertNotEquals(null,records[0].Opportunity__c);
		System.assertNotEquals('',records[0].Opportunity__c);
		List<Opportunity> opportunities = [Select Id, Name from Opportunity where Id = :records[0].Opportunity__c];
		System.assertEquals(1,opportunities.size());
		delete opportunities;
		records = [Select Id, Opportunity__c from iMis_Booth__c];
		System.assertEquals(null,records[0].Opportunity__c);
		*/
		Test.startTest();
		/* having iMis booth records without opportunities is the initial condition of the batch job -- test it now */
		ImisBoothSalesHistoryBatchConversion convert = new ImisBoothSalesHistoryBatchConversion();
		Database.executeBatch(convert);
		Test.stopTest(); //makes batch job run
		/* requery and assert that an opportunity was created */
		List<iMis_Booth__c> records = [Select Id, Opportunity__c from iMis_Booth__c];
		System.assertNotEquals(null,records[0].Opportunity__c);
		List<Opportunity> opportunities = [Select Id, Name from Opportunity where Id = :records[0].Opportunity__c];
		System.assertEquals(1,opportunities.size());
	}

	//@isTest
	static void convertOneWithStateMappingTest(){
		User testUser = DataFactory.createUser();
		Account acct = new Account(Name = 'Test Account', BillingState='VA');
		insert acct;
		DataFactory.createTerritoryMapping('VA',testUser.Username);

		iMis_Booth__c booth = DataFactory.createImisBoothSalesHistory('2015',false);
		booth.Show__c = DataFactory.createShowPublication('Testpub', true).Id;
		booth.Account_Name__c = acct.Id;
		insert booth;
		//trigger should fire after insert of Booth record and newly created Opportunity should have the correct owner
		Opportunity newOpportunity = [Select Id, Owner.Username from Opportunity limit 1];
		System.assertEquals(testUser.Username.toLowerCase(), newOpportunity.Owner.Username.toLowerCase(),'Owner ID should have been assigned via the territory mapping.');
	}

	static void setupData(){
		iMis_Booth__c booth = DataFactory.createImisBoothSalesHistory('2015');
	}
}