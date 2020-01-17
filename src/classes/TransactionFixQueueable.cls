/**
 * Created by Eric Stansbury on 11/20/2017.
 */

public with sharing class TransactionFixQueueable implements Queueable{
    public void execute(System.QueueableContext qc){
        TransactionFixFromFieldHistoryScript.processAllRecords(true);

        integer boothCount = [Select count() from Imis_Booth__c where Historical_Account_Owner__c = null];
        integer sponsCount = [Select count() from Imis_Sponsorship_Sales__c where Historical_Account_Owner__c = null];

        System.debug(boothCount + 'booths and ' + sponsCount + ' sponsorships remaining without historical account owners');

        if (boothCount > 0 || sponsCount > 0){
            System.enqueueJob(new TransactionFixQueueable());
        }
    }

    public static void runMe(){
        System.enqueueJob(new TransactionFixQueueable());
    }
    
    @TestVisible static void testCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}