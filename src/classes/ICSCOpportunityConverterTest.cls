/**
 * Created by Eric Stansbury on 9/24/2018.
 */

@isTest
public class ICSCOpportunityConverterTest {
    @isTest static void testCreateOrder(){
        Contract contract = [Select Id from Contract limit 1];
        Account account = [Select Id from Account limit 1];
        Opportunity opportunity = [Select Id, AccountId from Opportunity limit 1];

        ICSCOpportunityConverter.createOrder(contract.Id, opportunity, account);
    }

    @testSetup static void testSetup(){
        DataFactory.createOpp2OrderMapping();

        insert new RTSLabs__Automation_Config__c(
                Name = 'TestConfig',
                RTSLabs__AutomateConversion__c = false,
                RTSLabs__Create_Order_Implementation__c = 'ICSCOpportunityConverter'
        );

        Account acct = DataFactory.createAccount('test', true);
        Opportunity opp = DataFactory.createOpp('test', acct.Id, DateTime.now().addDays(1), true);
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        Id standardPricebookId = Test.getStandardPricebookId();
        List<Product2> products = new List<Product2>();
        List<Fulfillment_Item__c> items = null;
        //ID standardPricebookId = Test.getStandardPricebookId();

        Contract contract = DataFactory.createContract(Date.today(), acct.Id, true);

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
    }
}