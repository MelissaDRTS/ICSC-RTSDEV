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
 // test iMIS Sponsorship Sales History roll up to Account Sales Summary
@isTest
private class TestImisSponsorshipSalesTrigger
{

    static testMethod void TestImisSponsorshipSalesHistoryTrigger()
    {
        List <Account_Sales_Summary__c> acctSalesSummaryList = null;

        //create an account
        Account account = null;
        account = new Account(Name = 'NewAccount');
        insert account;
        
        //create a publication
        Show_Publications__c publication = null;
        publication = new Show_Publications__c(Name = 'NewPublication');
        insert publication;
        
        //create a iMIS Sponsorship	Sales History entry
        iMIS_Sponsorship_Sales__c SponsorshipSales = null;
        SponsorshipSales = new iMIS_Sponsorship_Sales__c(Account_Name__c = account.Id,
        			Show__c = publication.id,
        			Year__c = '2014',
        			Cost__c = 100.00);
        insert SponsorshipSales;
        			
        //Start Test
        //Test Inserts
        acctSalesSummaryList = [SELECT Id, P_C_Sponsorship__c, Year__c FROM Account_Sales_Summary__c WHERE Year__c =: SponsorshipSales.Year__c AND Account_Name__c =: account.Id];
        //System.assertEquals(100.00, acctSalesSummaryList[0].P_C_Sponsorship__c);	
                
        //Test Update on Year
        SponsorshipSales.Year__c = '2015';
        update SponsorshipSales;
        
        acctSalesSummaryList = [SELECT Id, P_C_Sponsorship__c, Year__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: account.Id];
       	//test that the year 2015 was updated to hold the amount of 100.00 and 2014 is now 0
       		for (Account_Sales_Summary__c assl : acctSalesSummaryList)
       		{
	       		if(assl.Year__c == '2015')
	       		{
	       			System.assertEquals(100.00, assl.P_C_Sponsorship__c);
	       		}
	       			else if(assl.Year__c == '2014')
	       			{
	       				System.assertEquals(0, assl.P_C_Sponsorship__c);
	       			}
       		}
       		
       	//Test Update on Cost
        SponsorshipSales.Cost__c = 200.00;
        update SponsorshipSales;
        acctSalesSummaryList = [SELECT Id, P_C_Sponsorship__c, Year__c FROM Account_Sales_Summary__c WHERE Year__c =: SponsorshipSales.Year__c AND Account_Name__c =: account.Id];
        System.assertEquals(200.00, acctSalesSummaryList[0].P_C_Sponsorship__c);
       		
       	//Test Delete Account Sales Summary before delete of Sponsorship Sales History entry
       	//delete acctSalesSummaryList[0];
       	//acctSalesSummaryList = [SELECT Id, P_C_Advertising__c, Year__c FROM Account_Sales_Summary__c WHERE Year__c =: SponsorshipSales.Year__c AND Account_Name__c =: account.Id];
        //System.assertEquals(0, acctSalesSummaryList.size());	
       			
       	//Test Delete
       	delete SponsorshipSales;
       	acctSalesSummaryList = [SELECT Id, P_C_Sponsorship__c, Year__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: account.Id];
     	//test that there are still 2 entries but their amounts are both 0.00
     	System.assertEquals(2, acctSalesSummaryList.size());
     	
     	for (Account_Sales_Summary__c assl : acctSalesSummaryList)
       		{
       			System.assertEquals(0, assl.P_C_Sponsorship__c);
       		}
     	
     	//Test Undelete
     	undelete SponsorshipSales;
       	acctSalesSummaryList = [SELECT Id, P_C_Sponsorship__c, Year__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: account.Id];
     	//test that there are still 2 entries and their amounts are correct
     	System.assertEquals(2, acctSalesSummaryList.size());
     	
     	for (Account_Sales_Summary__c assl : acctSalesSummaryList)
       		{

	       		if(assl.Year__c == '2015')
	       		{
	       			System.assertEquals(200.00, assl.P_C_Sponsorship__c);
	       		}
	       			else if(assl.Year__c == '2014')
	       			{
	       				System.assertEquals(0, assl.P_C_Sponsorship__c);
	       			}
       		}
    }
}