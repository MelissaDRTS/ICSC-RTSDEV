/**
 * Created by Eric Stansbury on 11/20/2017.
 */

public with sharing class TransactionFixFromFieldHistoryScript {
    static boolean useCurrentOwnerIfNoneFound = true;

    public static void processAllRecords(boolean doUpdate){
        processBoothSales([Select Id, Account_Name__r.OwnerId, Account_Name__c, CreatedDate from Imis_Booth__c where Historical_Account_Owner__c = null limit 48], doUpdate);
        processSponsorshipSales([Select Id, Account_Name__r.OwnerId, Account_Name__c, CreatedDate from Imis_Sponsorship_Sales__c where Historical_Account_Owner__c = null limit 48], doUpdate);
    }

    public static void processBoothSales(List<imis_Booth__c> boothSales, boolean doUpdate){
        for (Imis_Booth__c boothSale : boothSales){
            Id historicalOwnerId = getOwnerIdAtDate(boothSale.Account_Name__c, boothSale.CreatedDate);

            if (historicalOwnerId != null){
                boothSale.Historical_Account_Owner__c = historicalOwnerId;
                System.debug('Booth sale ' + boothSale.Id + ' updated with owner ID ' + historicalOwnerId);
            }else if (useCurrentOwnerIfNoneFound){
                boothSale.Historical_Account_Owner__c = boothSale.Account_Name__r.OwnerId;
                System.debug('Booth sale ' + boothSale.Id + ' couldn\'t find an owner in AccountHistory, so using current account owner ' + boothSale.Account_Name__r.OwnerId);
            }else{
                System.debug('Booth sale ' + boothSale.Id + ' not updated');
            }
        }

        if (doUpdate) update boothSales;
    }

    public static void processSponsorshipSales(List<imis_Sponsorship_sales__c> sponsorshipSales, boolean doUpdate){
        for (imis_Sponsorship_sales__c sponsorshipSale : sponsorshipSales){
            Id historicalOwnerId = getOwnerIdAtDate(sponsorshipSale.Account_Name__c, sponsorshipSale.CreatedDate);

            if (historicalOwnerId != null){
                sponsorshipSale.Historical_Account_Owner__c = historicalOwnerId;
                System.debug('Sponsorship sale ' + sponsorshipSale.Id + ' updated with owner ID ' + historicalOwnerId);
            }else if (useCurrentOwnerIfNoneFound){
                sponsorshipSale.Historical_Account_Owner__c = sponsorshipSale.Account_Name__r.OwnerId;
                System.debug('Sponsorship sale ' + sponsorshipSale.Id + ' couldn\'t find an owner in AccountHistory, so using current account owner ' + sponsorshipSale.Account_Name__r.OwnerId);
            }else{
                System.debug('Sponsorship sale ' + sponsorshipSale.Id + ' not updated');
            }
        }

        if (doUpdate) update sponsorshipSales;
    }

    public static Id getOwnerIdAtDate(Id accountId, Datetime myDate){
        List<AccountHistory> accountHistory = [
                Select Id, OldValue
                from AccountHistory
                where AccountId = :accountId
                  and Field = 'Owner'
                  and CreatedDate >= :myDate
                order by CreatedDate desc
                limit 1
        ];

        return (accountHistory.size() > 0) ? (Id)accountHistory[0].OldValue : null;
    }
}