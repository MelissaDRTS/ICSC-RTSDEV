public with sharing class ImisSponsorshipSalesConverter {
	static boolean throwExceptionOnMissingField = false;

	/*
	 *	conversion logic here
	 */
	public static void insertOpportunitiesWithLineItems(List<iMIS_Sponsorship_Sales__c> newRecords, Map<Id,String> accountIdToBillingStateMap)
	{
		System.debug('insertOpportunitiesWithLineItems called on '+newRecords.size()+' records.');
		Map<Id,Opportunity> boothToOpportunityToInsertMap = new Map<Id,Opportunity>();
		Map<String,Id> userNameToUserIdMap = getUserNameToUserIdMap();
		List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
		// iterate over newRecords twice. first for Opportunities, then for line items
		for (iMIS_Sponsorship_Sales__c ash : newRecords)
		{	
			if (throwExceptionOnMissingField){
				if (ash.Transaction_Date__c == null) throw new ImisSponsorshipSalesConverterException('Cannot create opportunity: Transaction date on record '+ash.Name+' ('+ash.Id+') is null.');
				if (ash.Quantity__c == null) throw new ImisSponsorshipSalesConverterException('Cannot create opportunity: Quantity on record '+ash.Name+' ('+ash.Id+') is null.');
				if (ash.Quantity__c == 0) throw new ImisSponsorshipSalesConverterException('Cannot create opportunity: Quantity on record '+ash.Name+' ('+ash.Id+') is zero.');
				if (ash.Cost__c == null) throw new ImisSponsorshipSalesConverterException('Cannot create opportunity: Cost on record '+ash.Name+' ('+ash.Id+') is null.');
			}
			if (ash.Transaction_Date__c != null && ash.Quantity__c != null && ash.Quantity__c > 0 && ash.Cost__c != null){
				Opportunity newOpp = new Opportunity(
						Name = 'Sponsorship Sales '+ash.Name,
						AccountId = ash.Account_Name__c,
						//Booth_Contact_Name__c = ash.Booth_Contact__c,
						//Booth_Contact_Email__c = ash.Booth_Contact_Email__c,
						CloseDate = ash.Transaction_Date__c,
						StageName = 'Closed Won'
				);
				String ownerId = getSponsorshipUserId(ash,accountIdToBillingStateMap,userNameToUserIdMap);
				if (ownerId != null){
					newOpp.OwnerId = ownerId;
				}
				boothToOpportunityToInsertMap.put(
					ash.Id,
					newOpp
				);
			}else{ //since we didn't throw an exception, do some logging
				if (ash.Transaction_Date__c == null) System.debug('Cannot create opportunity: Transaction date on record '+ash.Name+' ('+ash.Id+') is null.');
				if (ash.Quantity__c == null) System.debug('Cannot create opportunity: Quantity on record '+ash.Name+' ('+ash.Id+') is null.');
				if (ash.Quantity__c == 0) System.debug('Cannot create opportunity: Quantity on record '+ash.Name+' ('+ash.Id+') is zero.');
				if (ash.Cost__c == null) System.debug('Cannot create opportunity: Cost on record '+ash.Name+' ('+ash.Id+') is null.');	
			}
		}
		insert boothToOpportunityToInsertMap.values();
		System.debug('insertOpportunitiesWithLineItems inserted '+boothToOpportunityToInsertMap.values().size()+' opportunity records.');
		Id sponsorshipPricebookEntryId = getSponsorshipSalesPricebookEntryId();
		for (iMIS_Sponsorship_Sales__c ash : newRecords){
			Opportunity opp = boothToOpportunityToInsertMap.get(ash.Id); //null here means the opportunity did not get created
			if (opp != null){
				decimal unitPrice = (ash.Cost__c / ash.Quantity__c);
				lineItemsToInsert.add(
					new OpportunityLineItem(
						//Description = ash.Type_of_Booth_Purchased__c,
						PricebookEntryId = sponsorshipPricebookEntryId,
						OpportunityId = opp.Id,
						Quantity = ash.Quantity__c,
						Sale_Type__c = ash.Sale_Type__c,
						Show_Event_Publication__c = ash.Show__c,
						UnitPrice = unitPrice,
						Year__c = ash.Year__c
					)
				);
			}
		}
		insert lineItemsToInsert;
		System.debug('insertOpportunitiesWithLineItems inserted '+lineItemsToInsert.size()+' opportunity records.');
		//re-query and update the sales history records
		List<iMIS_Sponsorship_Sales__c> toUpdate = [Select Id from iMIS_Sponsorship_Sales__c where Id in :boothToOpportunityToInsertMap.keySet()];
		for (iMIS_Sponsorship_Sales__c b : toUpdate){
			b.Opportunity__c = boothToOpportunityToInsertMap.get(b.Id).Id;
		}
		update toUpdate;
	}

	/*
	 *	static utility methods
	 */
	static Id getSponsorshipSalesPricebookEntryId(){
		if (Test.isRunningTest()){
			Product2 genericBoothProduct = DataFactory.createProduct('Booth','Booth',false);
			genericBoothProduct.ProductCode = 'BTH123';
			insert genericBoothProduct;
			Id standardPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [Select Id from Pricebook2 where IsStandard = true].Id;
			return DataFactory.createPricebookEntry(genericBoothProduct.Id, standardPricebookId, 0, true).Id;
		}else{
			List<PricebookEntry> pbes = [Select ID from PricebookEntry where Product2.Name = 'Sponsorship Sales' and Product2.ProductCode = 'SPNSR123' limit 1];
			if (pbes.size() == 0) throw new ImisSponsorshipSalesConverterException('Pricebook entry for generic sales product with name \'Sponsorship Sales\' and Product Code \'SPNSR123\' not found.');
			return pbes[0].Id;
		}
	}

	public static Id getSponsorshipUserId(iMIS_Sponsorship_Sales__c s, Map<Id,String> accountIdToBillingStateMap, Map<String,Id> userNameToUserIdMap) {
		String territoryName = accountIdToBillingStateMap.get(s.Account_Name__c);
		String username = getTerritoryToUsernameMap().get(territoryName);
		if (String.isBlank(username)) {
			System.debug('getSponsorshipUserId: userMapping.size() == 0');
			return null;
		} else {
			System.debug('Username '+username+' found for territory '+territoryName);
		}
		Id retrievedId = userNameToUserIdMap.get(username.toLowerCase());
		if (retrievedId == null){
			System.debug('No user id for user name '+username+' found.');
		}
		return retrievedId;
	}

	public static Map<Id,String> getAccountIdToBillingStateMap(List<iMIS_Sponsorship_Sales__c> sponsorships){
		Map<Id,String> result = new Map<Id,String>();
		Set<String> accountIds = new Set<String>();

		for (iMIS_Sponsorship_Sales__c sponsor : sponsorships){
			accountIds.add(sponsor.Account_Name__c);
		}
		List<Account> accounts = [Select Id, BillingState from Account where Id in :accountIds];
		for (Account acct : accounts){
			result.put(acct.Id,acct.BillingState);
		}
		return result;
	}

	public static Map<String,Id> getUserNameToUserIdMap(){
		List<Territory_User_Mapping__c> mappings = [Select Username__c	, Territory__c from Territory_User_Mapping__c];
		System.debug('mappings: '+mappings);
		Map<String,Id> result = new Map<String,Id>();
		Set<String> usernames = new Set<String>();
		for (Territory_User_Mapping__c mapping : mappings){
			usernames.add(mapping.Username__c	);
		}
		List<User> users = [Select Id, Username from User where Username in :usernames];
		System.debug('getUserNameToUserIdMap returned '+users.size()+' users for '+usernames.size()+' usernames');
		for (User user : users){
			result.put(user.Username.toLowercase(),user.Id);
		}
		return result;
	}

	public static Map<String,String> getTerritoryToUsernameMap(){
		List<Territory_User_Mapping__c> userMapping = Territory_User_Mapping__c.getAll().values();
		Map<String,String> result = new Map<String,String>();
		for (Territory_User_Mapping__c m : userMapping){
			result.put(m.Territory__c, m.Username__c);
		}
		return result;
	}

	class ImisSponsorshipSalesConverterException extends Exception{}
}