/*
	BlackTab Group - MG - 11/2014
	Utiliy class that creates data for test classes
*/
@isTest
public class DataFactory 
{
	public static final String SHOW_PUBLICATION_PUBLICATION_TYPE_ID = '012j000000099B4AAI';
	public static final String SHOW_PUBLICATION_SHOW_EVENT_TYPE_ID = '012j000000099BEAAY';
	public static final String FULFILLMENT_ITEM_ADVERTISING_TYPE_ID = '012j00000009IE8AAM';
	public static final String FULFILLMENT_ITEM_SPONSORSHIP_TYPE_ID = '012j00000009IEDAA2';
	public static final String FULFILLMENT_ITEM_BOOTH_TYPE_ID = '012j00000009IEIAA2';
	 
	public static Account_Sales_Summary__c createAccountSalesSummary(ID accountId, decimal ads, decimal booths, decimal certs, decimal foundations, decimal funds, 
					decimal memberships, decimal pacs, decimal refunds, decimal registrations, decimal sponsors, boolean save)
	{
		List<Account_Sales_Summary__c> summaries = SmartFactory.createSObjectList('Account_Sales_Summary__c', false, 1);
		
		summaries[0].Account_Name__c = accountId;
       	summaries[0].Advertising__c = ads;
		summaries[0].Booth__c = booths;
		summaries[0].Certification_Fees__c = certs;
		summaries[0].Foundation_Fees__c = foundations;
		summaries[0].Fundraising__c = funds;
		summaries[0].Membership_Dues__c = memberships;
		summaries[0].PAC_Contributions__c = pacs;
		summaries[0].Refunds__c = refunds;
		summaries[0].Registration_Fees__c = registrations;
		summaries[0].Sponsorship__c = sponsors;
		
		if(save)
		{
			insert summaries;
		}
		
		return summaries[0];
	}
	
	public static Opportunity_Package__c createOpportunityPackage(ID sponsorPackageId, ID opportunityId, integer qty, boolean save)
	{
		List<Opportunity_Package__c> ops = SmartFactory.createSObjectList('Opportunity_Package__c', false, 1);
		
		ops[0].Opportunity__c = opportunityId;
       	ops[0].Sponsorship_Package__c = sponsorPackageId;
       	ops[0].Quantity__c = qty;
		
		if(save)
		{
			insert ops;
		}
		
		return ops[0];
	}
	
	public static Package_Line_Item__c createPackageLineItem(ID sponsorPackageId, ID productId, decimal salesPrice, decimal quantity, boolean save)
	{
		List<Package_Line_Item__c> plis = SmartFactory.createSObjectList('Package_Line_Item__c', false, 1);
		
		plis[0].Product__c = productId;
       	plis[0].Sponsorship_Package__c = sponsorPackageId;
       	plis[0].Sales_Price__c = salesPrice;
       	plis[0].Quantity__c = quantity;
       	plis[0].Insertion_Date__c = Date.today().addDays(1);
		plis[0].Line_Description__c = 'Test';
		
		if(save)
		{
			insert plis;
		}
		
		return plis[0];
	}
	
	public static Sponsorship_Package__c createSponsorshipPackage(ID showPublicationId, String name, boolean save)
	{
		List<Sponsorship_Package__c> sps = SmartFactory.createSObjectList('Sponsorship_Package__c', false, 1);
		
		sps[0].Show_Publication__c = showPublicationId;
       	sps[0].Name = name;
		
		if(save)
		{
			insert sps;
		}
		
		return sps[0];
	}
	
	public static Show_Publications__c createShowPublication(String name, boolean save){
		Id recordTypeId = [Select Id From RecordType Where SobjectType = 'Show_Publications__c' limit 1].Id;
		return createShowPublication(recordTypeId,name,save);
	}

	public static Show_Publications__c createShowPublication(ID recordTypeId, String name, boolean save)
	{
		List<Show_Publications__c> sps = SmartFactory.createSObjectList('Show_Publications__c', false, 1);
		
		sps[0].RecordTypeId = recordTypeId;
       	sps[0].Name = name;
		
		if(save)
		{
			insert sps;
		}
		
		return sps[0];
	}
	
	public static PricebookEntry createPricebookEntry(ID productId, ID pricebookId, decimal price, boolean save)
	{
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, IsActive = true, UnitPrice = price);
		
		if(save)
		{
			insert pbe;
		}
		
		return pbe;
	}
	
	public static Pricebook2 createPricebook(string Name, boolean save)
	{
		List<Pricebook2> pbs = SmartFactory.createSObjectList('Pricebook2', false, 1);
		
		pbs[0].Name = name;
       	pbs[0].IsActive = true;
		
		if(save)
		{
			insert pbs;
		}
		
		return pbs[0];
	}
	
	public static OpportunityLineItem createOpportunityLineItem(ID opportunityId, ID pricebookEntryId, decimal unitPrice, decimal quantity, boolean save)
	{
		List<OpportunityLineItem> lineItems = SmartFactory.createSObjectList('OpportunityLineItem', false, 1);
		
       	lineItems[0].PricebookEntryId = pricebookEntryId;
       	lineItems[0].Quantity = quantity;
       	lineItems[0].UnitPrice = unitPrice;
       	lineItems[0].OpportunityId = opportunityId;
       	
       	if(save)
       	{
       		insert lineItems;
       	}
       	
		return lineItems[0];
	}
	
	public static Opportunity createOpp(string name, ID accountId, DateTime closeDate, boolean save)
	{
		List<Opportunity> opps = SmartFactory.createSObjectList('Opportunity', false, 1);

		Contact contact = new Contact(LastName = name + ' Test Contact');
		insert contact;

		opps[0].Name = name;			
		opps[0].AccountId = accountId;
		opps[0].CloseDate = Date.today().addDays(90);
       	opps[0].StageName = 'In Discussions';
		opps[0].Billing_Contact__c = contact.Id;
       	
       	if(save)
       	{       	
       		insert opps;
       	}
       	
		return opps[0];
	}
		
	public static Account createAccount(String name, boolean save)
	{
		List<Account> accounts = SmartFactory.createSObjectList('Account', false, 1);
		
		if(save)
		{
       		insert accounts;
		}
       	
		return accounts[0];
	}
	
	public static Product2 createProduct(String name, String family, boolean save)
	{
		List<Product2> products = SmartFactory.createSObjectList('Product2', false, 1);
		
		products[0].Name = name;
		products[0].Family = family;
		products[0].IsActive = true;
		
		if(save)
		{
			insert products;
		}
		
		return products[0];
	}
	
	public static ImisServiceConfiguration__c createImisServiceConfig(String name, String endPoint, Datetime lastModified, integer numberOfRecords, integer row)
	{
		ImisServiceConfiguration__c accountConfig = new ImisServiceConfiguration__c();
		
		accountConfig.Name = name;
		accountConfig.AdminEmail__c = 'btgadmin+icsc@blacktabgroup.com';
		accountConfig.LastModified__c = lastModified;
		accountConfig.NumberOfRecords__c = numberOfRecords;
		accountConfig.StartingRow__c = row;
		accountConfig.EndPoint__c = endPoint;
		
		insert accountConfig;
		
		return accountConfig;
	}

	public static iMis_Booth__c createImisBoothSalesHistory(String year){
		return createImisBoothSalesHistory(year,true);
	}

	public static iMis_Booth__c createImisBoothSalesHistory(String year,boolean save){
		iMis_Booth__c booth = (iMis_Booth__c)SmartFactory.createSObject('iMis_Booth__c', save);
		System.debug('booth: '+booth);
		//booth.Account_Name__c = acct.Id;
		booth.Booth_Contact__c = 'Test Contact';
		booth.Booth_Contact_Email__c = 'Test@rtslabs.com';
		booth.Cost__c = 2;
		booth.Opportunity__c = null;
		booth.Quantity__c = 25;
		//booth.Show__c = show.Id;
		booth.Sale_Type__c = 'TEST';
		booth.Transaction_Date__c = Date.today();
		booth.Type_of_Booth_Purchased__c = 'Test Booth Type';
		booth.Year__c = year; 
		if (save) upsert booth;
		return booth;
	}

	public static iMIS_Sponsorship_Sales__c createImisSponsorshipSalesHistory(String year){
		return createImisSponsorshipSalesHistory(year,true);
	}

	public static iMIS_Sponsorship_Sales__c createImisSponsorshipSalesHistory(String year,boolean save){
		iMIS_Sponsorship_Sales__c sponsorship = (iMIS_Sponsorship_Sales__c)SmartFactory.createSObject('iMIS_Sponsorship_Sales__c', save);
		System.debug('sponsorship: '+sponsorship);
		//booth.Account_Name__c = acct.Id;
		sponsorship.Cost__c = 2;
		sponsorship.Opportunity__c = null;
		sponsorship.Quantity__c = 25;
		//sponsorship.Show__c = show.Id;
		sponsorship.Sale_Type__c = 'TEST';
		sponsorship.Transaction_Date__c = Date.today();
		sponsorship.Year__c = year; 
		if (save) upsert sponsorship;
		return sponsorship;
	}

	public static User createUser(){
        
        
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User user = new User(
			ProfileId = p.Id,
			Username = 'TestUser@test.com.test'+generateRandomString(5),
			LastName = 'Test',
			Email = 'TestUser@test.com',
			Alias = 'tz',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey='en_US',
			EmailEncodingKey='UTF-8',
			LanguageLocaleKey='en_US',
			IsActive = true
		);
		insert user;
		return user;
	}

	public static Invoice__c createInvoice(boolean save){
		Invoice__c invoice = new Invoice__c();
		//invoice.Name is auto-assigned
		//invoice.Description__c = 'Test Description';
		//invoice.Page__c = 'B11';
		//invoice.Size__c = '8 1/2 x 11';
		//invoice.Theme__c = 'Existential Dread';
		if (save) insert invoice;
		return invoice;
	}

	public static Invoice__c createInvoice(){
		return createInvoice(true);
	}


    public static Contract createContract(Date startDate, Id accountId, boolean save){
        Contract contract = new Contract(
                AccountId = accountId,
                StartDate = startDate,
                Status    = 'Draft');
        if (save) insert contract;
        return contract;
    }
    public static Contract createContract(Id accountId, boolean save){
        Date startDate = Date.today().addDays(30);
        return createContract(startDate, accountId, save);
    }

	public static Contract createContract(boolean save){
		Account account = createAccount('Test',true);
        return createContract(account.Id, save);
	}

	public static Order createOrder(boolean save){
		Account account = createAccount('Test Account',true);

		Order order = new Order(
			AccountId = account.Id,
			EffectiveDate = Date.today(),
			Status = 'Draft');
		
		if (save) insert order;
		return order;
	}

	public static Territory_User_Mapping__c createTerritoryMapping(String territory, String username){
		Territory_User_Mapping__c t = new Territory_User_Mapping__c(Name = 'Test Setting', Username__c = username, Territory__c = territory);
		insert t;
		return t;
	}
    
    static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static void createOpp2OrderMapping(){
        List<RTSLabs__Opp2Order_Field_Mapping__c> toInsert = new List<RTSLabs__Opp2Order_Field_Mapping__c>();
        /*
         *  opp -> order
         */
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.accountid',
            RTSLabs__Source_Object__c = 'opportunity',
            RTSLabs__Source_Field__c = 'accountid',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'accountid'
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.opportunityid',
            RTSLabs__Source_Object__c = 'opportunity',
            RTSLabs__Source_Field__c = 'id',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'opportunityid',
            RTSLabs__Read_Only__c = true
        ));
        /*
         *  contract -> order
         */
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.contractid',
            RTSLabs__Source_Object__c = 'contract',
            RTSLabs__Source_Field__c = 'id',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'contractid',
            RTSLabs__Read_Only__c = true
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.companysignedid',
            RTSLabs__Source_Object__c = 'contract',
            RTSLabs__Source_Field__c = 'companysignedid',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'companyauthorizedbyid'
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.companyauthorizeddate',
            RTSLabs__Source_Object__c = 'contract',
            RTSLabs__Source_Field__c = 'companysigneddate',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'companyauthorizeddate'
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.customerauthorizedbyid',
            RTSLabs__Source_Object__c = 'contract',
            RTSLabs__Source_Field__c = 'customersignedid',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'customerauthorizedbyid'
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='order.customerauthorizeddate',
            RTSLabs__Source_Object__c = 'contract',
            RTSLabs__Source_Field__c = 'customersigneddate',
            RTSLabs__Destination_Object__c = 'order',
            RTSLabs__Destination_Field__c = 'customerauthorizeddate'
        ));
        /*
         *  opp item -> order line item
         */
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='orderitem.pricebookentryid',
            RTSLabs__Source_Object__c = 'opportunitylineitem',
            RTSLabs__Source_Field__c = 'pricebookentryid',
            RTSLabs__Destination_Object__c = 'orderitem',
            RTSLabs__Destination_Field__c = 'pricebookentryid'
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='orderitem.quantity',
            RTSLabs__Source_Object__c = 'opportunitylineitem',
            RTSLabs__Source_Field__c = 'quantity',
            RTSLabs__Destination_Object__c = 'orderitem',
            RTSLabs__Destination_Field__c = 'quantity'
        ));
        toInsert.add(new RTSLabs__Opp2Order_Field_Mapping__c(
            Name='orderitem.unitprice',
            RTSLabs__Source_Object__c = 'opportunitylineitem',
            RTSLabs__Source_Field__c = 'unitprice',
            RTSLabs__Destination_Object__c = 'orderitem',
            RTSLabs__Destination_Field__c = 'unitprice'
        ));
        insert toInsert;
    }
}