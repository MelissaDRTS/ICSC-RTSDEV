@isTest
public with sharing class TestAccountSalesSummaryTrigger 
{
	static testMethod void testRollupsForParentAccountWithoutSalesSummary()
	{
		Account parent = DataFactory.createAccount('Parent', true);
		Account child1 = DataFactory.createAccount('Child 1', false);
		Account child2 = DataFactory.createAccount('Child 2', false);
		Account_Sales_Summary__c child1Summary = null;
		Account_Sales_Summary__c child2Summary = null;
		Account_Sales_Summary__c child3Summary = null;
		List<Account_Sales_Summary__c> parentSummaries = null;
		List<Account_Sales_Summary__c> childrenSummaries = new List<Account_Sales_Summary__c>();
		Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.AllowSave = true;
			
		child1.ParentId = child2.ParentId = parent.Id;
		Database.insert(child1, dml);
		Database.insert(child2, dml);
		
		Test.startTest();
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id];
			System.assert(parentSummaries.isEmpty());
			
			child1Summary = DataFactory.createAccountSalesSummary(child1.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, false);
			child1Summary.Year__c = '2014';
			insert child1Summary;
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id];
			
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(1, parentSummaries.size());
			System.assertEquals(1, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(2, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(3, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(4, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(5, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(6, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(7, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-8, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(9, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(10, parentSummaries[0].P_C_Sponsorship__c);
			
			child2Summary = DataFactory.createAccountSalesSummary(child2.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, false);
			child3Summary = DataFactory.createAccountSalesSummary(child2.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, false);
			child2Summary.Year__c = child3Summary.Year__c = '2014';
			childrenSummaries.add(child2Summary);
			childrenSummaries.add(child3Summary);
			insert childrenSummaries;
			//child2Summary.Year__c = '2015';
			//insert child2Summary;
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id];
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(1, parentSummaries.size());
			System.assertEquals(3, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(6, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(9, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(12, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(15, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(18, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(21, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-24, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(27, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(30, parentSummaries[0].P_C_Sponsorship__c);
			
			child2Summary.Year__c = '2015';
			child3Summary.Year__c = '2015';
			update childrenSummaries;
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c, Year__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id ORDER BY Year__c];
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(2, parentSummaries.size());
			System.assertEquals(1, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(2, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(3, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(4, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(5, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(6, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(7, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-8, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(9, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(10, parentSummaries[0].P_C_Sponsorship__c);
			System.assertEquals('2014', parentSummaries[0].Year__c);
			
			System.assertEquals(2, parentSummaries[1].P_C_Advertising__c);
			System.assertEquals(4, parentSummaries[1].P_C_Booth__c);
			System.assertEquals(6, parentSummaries[1].P_C_Certification_Fees__c);
			System.assertEquals(8, parentSummaries[1].P_C_Foundation_Fees__c);
			System.assertEquals(10, parentSummaries[1].P_C_Fundraising__c);
			System.assertEquals(12, parentSummaries[1].P_C_Membership_Dues__c);
			System.assertEquals(14, parentSummaries[1].P_C_PAC_Contributions__c);
			System.assertEquals(-16, parentSummaries[1].P_C_Refunds__c);
			System.assertEquals(18, parentSummaries[1].P_C_Registration_Fees__c);
			System.assertEquals(20, parentSummaries[1].P_C_Sponsorship__c);
			System.assertEquals('2015', parentSummaries[1].Year__c);
			
			delete childrenSummaries;
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c, Year__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id ORDER BY Year__c];
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(2, parentSummaries.size());
			System.assertEquals(1, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(2, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(3, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(4, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(5, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(6, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(7, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-8, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(9, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(10, parentSummaries[0].P_C_Sponsorship__c);
			System.assertEquals('2014', parentSummaries[0].Year__c);
			
			System.assertEquals(0, parentSummaries[1].P_C_Advertising__c);
			System.assertEquals(0, parentSummaries[1].P_C_Booth__c);
			System.assertEquals(0, parentSummaries[1].P_C_Certification_Fees__c);
			System.assertEquals(0, parentSummaries[1].P_C_Foundation_Fees__c);
			System.assertEquals(0, parentSummaries[1].P_C_Fundraising__c);
			System.assertEquals(0, parentSummaries[1].P_C_Membership_Dues__c);
			System.assertEquals(0, parentSummaries[1].P_C_PAC_Contributions__c);
			System.assertEquals(0, parentSummaries[1].P_C_Refunds__c);
			System.assertEquals(0, parentSummaries[1].P_C_Registration_Fees__c);
			System.assertEquals(0, parentSummaries[1].P_C_Sponsorship__c);
			System.assertEquals('2015', parentSummaries[1].Year__c);
			
			undelete childrenSummaries;
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c, Year__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id ORDER BY Year__c];
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(2, parentSummaries.size());
			System.assertEquals(1, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(2, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(3, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(4, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(5, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(6, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(7, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-8, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(9, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(10, parentSummaries[0].P_C_Sponsorship__c);
			System.assertEquals('2014', parentSummaries[0].Year__c);
			
			System.assertEquals(2, parentSummaries[1].P_C_Advertising__c);
			System.assertEquals(4, parentSummaries[1].P_C_Booth__c);
			System.assertEquals(6, parentSummaries[1].P_C_Certification_Fees__c);
			System.assertEquals(8, parentSummaries[1].P_C_Foundation_Fees__c);
			System.assertEquals(10, parentSummaries[1].P_C_Fundraising__c);
			System.assertEquals(12, parentSummaries[1].P_C_Membership_Dues__c);
			System.assertEquals(14, parentSummaries[1].P_C_PAC_Contributions__c);
			System.assertEquals(-16, parentSummaries[1].P_C_Refunds__c);
			System.assertEquals(18, parentSummaries[1].P_C_Registration_Fees__c);
			System.assertEquals(20, parentSummaries[1].P_C_Sponsorship__c);
			System.assertEquals('2015', parentSummaries[1].Year__c);
		Test.stopTest();
	}
	
	static testMethod void testRollupsForParentAccountWithSalesSummary()
	{
		Account parent = DataFactory.createAccount('Parent', true);
		Account child1 = DataFactory.createAccount('Child 1', false);
		Account_Sales_Summary__c parentSummary = null;
		Account_Sales_Summary__c child1Summary = null;
		List<Account_Sales_Summary__c> parentSummaries = null;
		List<Account_Sales_Summary__c> childrenSummaries = new List<Account_Sales_Summary__c>();
		Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.AllowSave = true;
			
		child1.ParentId = parent.Id;
		Database.insert(child1, dml);
		
		Test.startTest();
			parentSummary = DataFactory.createAccountSalesSummary(parent.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, true);
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id];
			
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(1, parentSummaries.size());
			System.assertEquals(1, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(2, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(3, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(4, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(5, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(6, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(7, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-8, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(9, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(10, parentSummaries[0].P_C_Sponsorship__c);
			
			child1Summary = DataFactory.createAccountSalesSummary(child1.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, true);
			
			parentSummaries = [SELECT Id, P_C_Advertising__c, P_C_Booth__c, P_C_Certification_Fees__c, P_C_Foundation_Fees__c, P_C_Fundraising__c, P_C_Membership_Dues__c,
									P_C_PAC_Contributions__c, P_C_Refunds__c, P_C_Registration_Fees__c, P_C_Sponsorship__c FROM Account_Sales_Summary__c WHERE Account_Name__c =: parent.Id];
			
			System.assert(!parentSummaries.isEmpty());
			System.assertEquals(1, parentSummaries.size());
			System.assertEquals(2, parentSummaries[0].P_C_Advertising__c);
			System.assertEquals(4, parentSummaries[0].P_C_Booth__c);
			System.assertEquals(6, parentSummaries[0].P_C_Certification_Fees__c);
			System.assertEquals(8, parentSummaries[0].P_C_Foundation_Fees__c);
			System.assertEquals(10, parentSummaries[0].P_C_Fundraising__c);
			System.assertEquals(12, parentSummaries[0].P_C_Membership_Dues__c);
			System.assertEquals(14, parentSummaries[0].P_C_PAC_Contributions__c);
			System.assertEquals(-16, parentSummaries[0].P_C_Refunds__c);
			System.assertEquals(18, parentSummaries[0].P_C_Registration_Fees__c);
			System.assertEquals(20, parentSummaries[0].P_C_Sponsorship__c);
		Test.stopTest();
	}
	
	static testMethod void testAccountSalesSummaryValidation()
	{
		Account child1 = DataFactory.createAccount('Child 1', true);
		
		Test.startTest();
			DataFactory.createAccountSalesSummary(child1.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, true);
			
			try
			{
				DataFactory.createAccountSalesSummary(child1.Id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, true);
				System.assert(false);
			}
			catch(Exception ex)
			{
				System.assert(true);
			}
			
		Test.stopTest();
	}
}