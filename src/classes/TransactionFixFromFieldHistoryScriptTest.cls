/**
 * Created by Eric Stansbury on 11/20/2017.
 */

@isTest
public with sharing class TransactionFixFromFieldHistoryScriptTest {
    @isTest static void doIt(){
        TransactionFixFromFieldHistoryScript.processAllRecords(true);
    }

    @isTest static void queueableTest(){
        TransactionFixQueueable.testCoverage();
    }

    @testSetup static void setupData(){
        User testUser = DataFactory.createUser();
        Account acct = new Account(Name = 'Test Account', BillingState='VA');
        insert acct;

        iMis_Booth__c booth = DataFactory.createImisBoothSalesHistory('2017',false);
        booth.Show__c = DataFactory.createShowPublication('Testpub', true).Id;
        booth.Account_Name__c = acct.Id;
        insert booth;

        iMIS_Sponsorship_Sales__c spons = DataFactory.createImisSponsorshipSalesHistory('2017',false);
        spons.Show__c = DataFactory.createShowPublication('Testpub', true).Id;
        spons.Account_Name__c = acct.Id;
        insert spons;

        booth = [Select Id, Historical_Account_Owner__c from Imis_Booth__c];
        booth.Historical_Account_Owner__c = null;
        update booth;

        spons = [Select Id, Historical_Account_Owner__c from Imis_Sponsorship_Sales__c];
        spons.Historical_Account_Owner__c = null;
        update spons;
    }
}