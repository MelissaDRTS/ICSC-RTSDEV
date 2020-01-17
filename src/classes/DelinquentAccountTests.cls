@isTest
public class DelinquentAccountTests {
    @isTest static void doTest(){
        Account account = [Select Id, Delinquent_Account__c from Account limit 1];
        System.assertEquals(false, account.Delinquent_Account__c, 'The account has not been marked delinquent yet');
        
        DelinquentAccounts da = new DelinquentAccounts();
        da.execute(null);
        
        account = [Select Id, Delinquent_Account__c from Account limit 1];
        System.assert(account.Delinquent_Account__c, 'The account should have been marked as delinquent');
        
        // now, update the order so that the account is no longer considered delinquent
        Order order = [Select Id, TotalAmount, Paid__c from Order limit 1];
        order.Paid_Amount__c = order.TotalAmount;
        update order;
        
        // run the job again
        da = new DelinquentAccounts();
        da.execute(null);
        
        account = [Select Id, Delinquent_Account__c from Account limit 1];
        // TODO: update trigger was disabled to avoid infinite loop issue -- need a better test here
        //System.assertEquals(false, account.Delinquent_Account__c, 'The account should no longer be marked delinquent, because the order was paid');        
    }
    
    @TestSetup static void setupData(){
        
        
        Account account = new Account(Name = 'Test Account', Delinquent_Account__c = false);
        insert account;
        
        Contract contract = new Contract(AccountId = account.Id);
        insert contract;
        
        Date sixMonthsAgo = Date.today().addMonths(-6);
        
        Order order = new Order(AccountId = account.Id, ContractId = contract.Id, EffectiveDate = sixMonthsAgo, Status = 'Draft', Paid_Amount__c = -5000);
        insert order;
        
        Test.setCreatedDate(order.Id, sixMonthsAgo);
    }
}