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
private class TestOpportunityTrigger 
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
            ops.add(DataFactory.createOpportunityPackage(sponsorPackages[0].Id, opps[1].Id, 2, false));
            insert ops;
            
            sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
            System.assertEquals(0, sponsorPackages[0].Units_Sold__c);
            System.assertEquals(4, sponsorPackages[0].Units_Pending__c);
            
            opps[0].StageName = 'Closed Won';
            
            try
            {
                update opps[0];
                system.assert(false);
            }
            catch(Exception ex)
            {
                System.assert(true);
            }
            
            sponsorPackages[0].Maximum_Units__c = 1;
            update sponsorPackages;
            
            update opps[0];
            
            sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
            System.assertEquals(2, sponsorPackages[0].Units_Sold__c);
            System.assertEquals(2, sponsorPackages[0].Units_Pending__c);
            
            delete opps[0];
            sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
            System.assertEquals(0, sponsorPackages[0].Units_Sold__c);
            System.assertEquals(2, sponsorPackages[0].Units_Pending__c);
            
            undelete opps[0];
            sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
            System.assertEquals(2, sponsorPackages[0].Units_Sold__c);
            System.assertEquals(2, sponsorPackages[0].Units_Pending__c);
            
            opps[0].StageName = 'In Discussions';
            update opps[0];
            
            sponsorPackages = [SELECT Id, Units_Sold__c, Units_Pending__c FROM Sponsorship_Package__c WHERE Id =:sponsorPackages[0].Id];
            System.assertEquals(0, sponsorPackages[0].Units_Sold__c);
            System.assertEquals(4, sponsorPackages[0].Units_Pending__c);
        Test.stopTest();
    }
    
    static testMethod void testCreateFulfillmentItems() 
    {
        Account acct = DataFactory.createAccount('test', true);
        Opportunity opp = DataFactory.createOpp('test', acct.Id, DateTime.now().addDays(1), true);
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        Id standardPricebookId = Test.getStandardPricebookId();
        List<Product2> products = new List<Product2>();
        List<Fulfillment_Item__c> items = null;
        //ID standardPricebookId = Test.getStandardPricebookId();
                        
        products.add(DataFactory.createProduct('Test Prod 1', 'Advertising', false));
        products.add(DataFactory.createProduct('Test Prod 2', 'Sponsorship', false));
        products.add(DataFactory.createProduct('Test Prod 3', 'Membership', false));
        products.add(DataFactory.createProduct('Test Prod 4', 'Booth', false));
        insert products;
        
        pbes.add(DataFactory.createPricebookEntry(products[0].Id, standardPricebookId, 10, false));
        pbes.add(DataFactory.createPricebookEntry(products[1].Id, standardPricebookId, 20, false));
        pbes.add(DataFactory.createPricebookEntry(products[2].Id, standardPricebookId, 30, false));
        pbes.add(DataFactory.createPricebookEntry(products[3].Id, standardPricebookId, 40, false));
        insert pbes;
                
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[0].Id, 10, 1, false));
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[1].Id, 10, 1, false));
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[2].Id, 10, 1, false));
        lineItems.add(DataFactory.createOpportunityLineItem(opp.Id, pbes[3].Id, 10, 1, false));
        insert lineItems;
        
        Test.startTest();
            items = [SELECT ID FROM Fulfillment_Item__c WHERE Opportunity__c =: opp.Id];            
            system.assertEquals(0, items.size());
            opp.StageName = 'Closed Won';
            opp.Signed_Contract_Uploaded__c = true;
            update opp;
            
            items = [SELECT ID, Product_Family__c, Product__r.Name, Opportunity__c  FROM Fulfillment_Item__c WHERE Opportunity__c =: opp.Id];     
            system.assertEquals(3, items.size());
            
        Test.stopTest();
    }
    
    static testMethod void testShowRollUpTotals() 
    {
        List<Account> accountList = new List<Account>();  
        List<Opportunity> oppList = new List<Opportunity>();    
        List<Show_Publications__c> showList = new List<Show_Publications__c>();
        List<Pricebook2> standardPricebook = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true AND IsStandard = true];
        List<Product2> products = new List<Product2>();                     //create a list of products
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();    
        List<Show_Publications__c>  showResultsList = null;

        //create account
        accountList.add(new Account(Name = 'TestAccount'));
        insert accountList;

        Contact contact = new Contact(LastName = 'TestContact', AccountId = accountList[0].Id);
        insert contact;

        //two opportunities attached to the same account
        oppList.add(new Opportunity(Name = 'FirstTestOpp',
                                    AccountId = accountList[0].Id,
                                    CloseDate = System.today(),
                                    StageName = 'In Discussions',
                                    Billing_Contact__c = contact.Id));
        oppList.add(new Opportunity(Name = 'SecondTestOpp', Signed_Contract_Uploaded__c = true,
                                    AccountId = accountList[0].Id,
                                    CloseDate = System.today(),
                                    StageName = 'Closed Won',
                                    Billing_Contact__c = contact.Id));
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
        pbe = new PricebookEntry(   Product2Id = products[0].Id,
                                    UnitPrice = 100,
                                    Pricebook2Id = Test.getStandardPricebookId(),
                                    IsActive = true);   
        insert pbe; 
        
        //add the product to an opportunity creating opportunityLineItem
        oliList.add(new OpportunityLineItem(    OpportunityId = oppList[0].Id,
                                        Quantity = 2,                  
                                        UnitPrice = pbe.UnitPrice, 
                                        PricebookEntryId = pbe.Id,
                                        Show_Event_Publication__c = showList[0].Id));   
        oliList.add(new OpportunityLineItem(    OpportunityId = oppList[1].Id,
                                        Quantity = 1,                  
                                        UnitPrice = pbe.UnitPrice, 
                                        PricebookEntryId = pbe.Id,
                                        Show_Event_Publication__c = showList[0].Id));                                   
        insert oliList; 
        
        //test the inserts
        showResultsList =   [   SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
                                FROM Show_Publications__c
                                WHERE Id =: showList[0].Id];
        System.assertEquals(200,showResultsList[0].Total_Opps_in_Pipeline__c);
        System.assertEquals(100,showResultsList[0].Total_Won_Opps__c);
        
        //test update
        oppList[0].StageName = 'Closed Won';
        oppList[0].Signed_Contract_Uploaded__c = true;
        update oppList; 
        showResultsList =   [   SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
                                FROM Show_Publications__c
                                WHERE Id =: showList[0].Id];
        System.assertEquals(0,showResultsList[0].Total_Opps_in_Pipeline__c);
        System.assertEquals(300,showResultsList[0].Total_Won_Opps__c);
                                    
        delete oppList[1];
        showResultsList =   [   SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
                                FROM Show_Publications__c
                                WHERE Id =: showList[0].Id];
        System.assertEquals(0,showResultsList[0].Total_Opps_in_Pipeline__c);
        System.assertEquals(200,showResultsList[0].Total_Won_Opps__c);
        
        undelete oppList[1];
        showResultsList =   [   SELECT Id, Total_Won_Opps__c, Total_Opps_in_Pipeline__c
                                FROM Show_Publications__c
                                WHERE Id =: showList[0].Id];
        System.assertEquals(0,showResultsList[0].Total_Opps_in_Pipeline__c);
        System.assertEquals(300,showResultsList[0].Total_Won_Opps__c);
        
    }

    @testSetup static void setupData(){
        insert new RTSLabs__Automation_Config__c(
            Name = 'TestConfig',
            RTSLabs__AutomateConversion__c = false,
            RTSLabs__Create_Order_Implementation__c = 'ICSCOpportunityConverter'
        );
    }
}