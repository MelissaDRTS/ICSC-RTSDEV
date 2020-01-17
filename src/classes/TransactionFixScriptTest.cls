/**
 * Created by Eric Stansbury on 10/30/2017.
 */

@isTest
public class TransactionFixScriptTest {
    static Date testDate = Date.newInstance(2017,1,2); // date between 2017/1/17 and 2017/8/15

    @isTest static void testMe(){
        iMIS_Booth__c booth = [Select Id, Historical_Account_Owner__c, Account_Name__r.Owner.Id from iMIS_Booth__c limit 1];
        System.assertEquals(booth.Historical_Account_Owner__c, booth.Account_Name__r.Owner.Id, 'The process should have populated the historical account owner field.');

        TransactionFixScript.processAllRecords();
        booth = [Select Id, Historical_Account_Owner__c, Account_Name__r.Owner.Id from iMIS_Booth__c limit 1];
        System.assertNotEquals(booth.Historical_Account_Owner__c, booth.Account_Name__r.Owner.Id, 'The owner should have been updated by the method call.');
    }

    @testSetup static void setupData(){
        User testUser = DataFactory.createUser();
        Account acct = new Account(Name = 'Test Account', BillingState='VA');
        insert acct;

        iMis_Booth__c booth = DataFactory.createImisBoothSalesHistory('2017',false);
        booth.Show__c = DataFactory.createShowPublication('Testpub', true).Id;
        booth.Account_Name__c = acct.Id;
        insert booth;

        Test.setCreatedDate(booth.Id, testDate);

        String ownerName = [Select Name from User where Id = :testUser.Id limit 1][0].Name;
        insert new Transaction_Fix__c(Account_Name__c = 'Test Account', Account_Owner_Name__c = ownerName);
    }
}