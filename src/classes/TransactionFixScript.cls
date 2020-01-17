/**
 * Created by Eric Stansbury on 10/30/2017.
 */

public class TransactionFixScript {
    static Date startDate = Date.newInstance(2017, 1, 1);
    static Date endDate = Date.newInstance(2017, 8, 25); //Date.newInstance(2017,8,15);

    public static void processAllRecords(){
        processRecords(
            [Select Id, Account_Name__c, Account_Owner_Name__c from Transaction_Fix__c where Processed__c = false]
        );
    }

    public static void processRecords(List<Transaction_Fix__c> transactionFixes){
        List<String> accountNames = new List<String>();
        List<String> ownerNames = new List<String>();
        for (Transaction_Fix__c transactionFix : transactionFixes){
            accountNames.add(transactionFix.Account_Name__c);
            ownerNames.add(transactionFix.Account_Owner_Name__c);
        }

        List<User> users = [Select Id, Name from User where Name in :ownerNames];
        Map<String, User> usersByName = new Map<String,User>();
        for (User u : users){
            usersByName.put(u.Name, u);
        }

        //
        //  get booth sales in the date range by account name
        //
        List<iMIS_Booth__c> boothSales = [
                Select Id, Historical_Account_Owner__c, Account_Name__r.Name from iMIS_Booth__c
                where Account_Name__r.Name in :accountNames
                  and CreatedDate >= :startDate
                  and CreatedDate < :endDate];

        Map<String, List<imis_Booth__c>> boothSalesByAccountName = new Map<String, List<imis_Booth__c>>();
        for (iMIS_Booth__c boothSale : boothSales){
            if (boothSalesByAccountName.get(boothSale.Account_Name__r.Name) == null){
                boothSalesByAccountName.put(boothSale.Account_Name__r.Name, new List<iMIS_Booth__c>());
            }
            boothSalesByAccountName.get(boothSale.Account_Name__r.Name).add(boothSale);
        }

        //
        //  get sponsorship sales in the date range by account name
        //
        List<iMIS_Sponsorship_Sales__c> sponsorshipSales = [
                Select Id, Historical_Account_Owner__c, Account_Name__r.Name from iMIS_Sponsorship_Sales__c
                where Account_Name__r.Name in :accountNames
                and CreatedDate >= :startDate
                and CreatedDate < :endDate];

        Map<String, List<iMIS_Sponsorship_Sales__c>> sponsorshipSalesByAccountName = new Map<String, List<iMIS_Sponsorship_Sales__c>>();
        for (iMIS_Sponsorship_Sales__c sponsorshipSale : sponsorshipSales){
            if (sponsorshipSalesByAccountName.get(sponsorshipSale.Account_Name__r.Name) == null){
                sponsorshipSalesByAccountName.put(sponsorshipSale.Account_Name__r.Name, new List<iMIS_Sponsorship_Sales__c>());
            }
            sponsorshipSalesByAccountName.get(sponsorshipSale.Account_Name__r.Name).add(sponsorshipSale);
        }

        //
        // iterate back over the Transaction Fix rows and update the transactions
        //
        List<imis_Booth__c> updateBooths = new List<Imis_Booth__c>();
        List<Imis_Sponsorship_Sales__c> updateSponsorships = new List<Imis_Sponsorship_Sales__c>();

        for (Transaction_Fix__c transactionFix : transactionFixes){
            transactionFix.Processing_Info__c = '';
            List<iMIS_Booth__c> myBoothSales = boothSalesByAccountName.get(transactionFix.Account_Name__c);
            List<iMIS_Sponsorship_Sales__c> mySponsorshipSales = sponsorshipSalesByAccountName.get(transactionFix.Account_Name__c);
            String boothIdsString = '';
            String sponsorshipIdsString = '';

            User owner = usersByName.get(transactionFix.Account_Owner_Name__c);
            if (myBoothSales == null && mySponsorshipSales == null){
                transactionFix.Processing_Info__c = 'No booth or sponsorship sales found for account name ' + transactionFix.Account_Name__c;
                transactionFix.Processed__c = true;
            }
            else if (owner == null){
                transactionFix.Processing_Error__c = 'Failed to update records: no User found with name ' + transactionFix.Account_Owner_Name__c;
            }else{
                if (myBoothSales != null){
                    for (iMIS_Booth__c boothSale : myBoothSales){
                        boothSale.Historical_Account_Owner__c = owner.Id;
                        if (boothIdsString.length() > 0){
                            boothIdsString += ',';
                        }
                        boothIdsString += boothSale.Id;
                    }
                    updateBooths.addAll(myBoothSales);
                }

                if (mySponsorshipSales != null){
                    for (iMIS_Sponsorship_Sales__c sponsorshipSale : mySponsorshipSales){
                        sponsorshipSale.Historical_Account_Owner__c = owner.Id;
                        if (sponsorshipIdsString.length() > 0){
                            sponsorshipIdsString += ',';
                        }
                        sponsorshipIdsString += sponsorshipSale.Id;
                    }
                    updateSponsorships.addAll(mySponsorshipSales);
                }

                transactionFix.Processing_Info__c = 'Updated booth sales ' + boothIdsString +' and sponsorship sales ' + sponsorshipIdsString + ' with owner '+owner.Id;
                transactionFix.Processed__c = true;
            }
        }

        update updateBooths;
        update updateSponsorships;
        update transactionFixes;
    }
}