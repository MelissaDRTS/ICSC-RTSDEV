/**
 * Created by Eric Stansbury on 6/7/2018.
 */

@isTest public class OrderTriggerHandlerTest {
    @isTest static void doTest(){
        Account account = [Select Id, Delinquent_Account__c from Account limit 1];
        System.assertEquals(false, account.Delinquent_Account__c, 'The account has not been marked delinquent yet');


        // update the order so the trigger fires and flags the account as delinquent
        Order order = [Select Id, Paid__c from Order limit 1];
        order.Billing_Notes__c = '12345678';
        order.EffectiveDate = Date.today().addMonths(-6); // this field doesn't matter -- just picked a field to update
        update order;

        account = [Select Id, Delinquent_Account__c from Account limit 1];
        
        // TODO: update trigger was disabled to avoid infinite loop issue -- need a better test here
        // System.assert(account.Delinquent_Account__c, 'The account should have been marked as delinquent by the Order after update trigger');
    }

    @TestSetup static void setupData(){
        Account account = new Account(Name = 'Test Account', Delinquent_Account__c = false);
        insert account;

        Contract contract = new Contract(AccountId = account.Id);
        insert contract;

        Date sixMonthsAgo = Date.today().addMonths(-6);

        Order order = new Order(AccountId = account.Id, ContractId = contract.Id, EffectiveDate = sixMonthsAgo, Status = 'Draft');
        insert order;

        Test.setCreatedDate(order.Id, sixMonthsAgo);
    }
}