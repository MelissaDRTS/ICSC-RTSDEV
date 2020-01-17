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
@isTest
private class TestAccountTrigger {

    static testMethod void testRecordTypeUpdate() 
    {
        Account parent1 = DataFactory.createAccount('Parent 1', false);
        Account parent2 = DataFactory.createAccount('Test Parent 2', false);
        Account acct = DataFactory.createAccount('Account 1', false);
        Account acct2 = DataFactory.createAccount('Test 1', false);
        List<Account> accounts = new List<Account>();
        ID customerRecordType = AccountUtility.getCustomerRecordTypeId();
        ID parentCustomerRecordType = AccountUtility.getParentCustomerRecordTypeId();
        
        parent1.RecordTypeId = parent2.RecordTypeId = acct.RecordTypeId = customerRecordType;
        accounts.add(parent1);
        accounts.add(parent2);
        accounts.add(acct);
        insert accounts;        
        AccountTriggerHandler.run = true;
        
        Test.startTest();
           	Database.DMLOptions dml = new Database.DMLOptions(); 
			dml.DuplicateRuleHeader.AllowSave = true;
		     
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		System.assertEquals(customerRecordType, a.RecordTypeId);
        	}
        	
        	acct.ParentId = parent1.Id;
        	update acct;
        	AccountTriggerHandler.run = true;
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(parentCustomerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        	
        	acct2.ParentId = parent2.Id;
        	Database.insert(acct2, dml);
        	AccountTriggerHandler.run = true;
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(parentCustomerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(parentCustomerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct2.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        	
        	acct.ParentId = parent2.Id;
        	update acct;
        	AccountTriggerHandler.run = true;        	
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(parentCustomerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct2.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        	
        	delete acct;
        	AccountTriggerHandler.run = true;
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(parentCustomerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct2.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        	
        	delete acct2;
        	AccountTriggerHandler.run = true;
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        	
        	undelete acct;
        	AccountTriggerHandler.run = true;
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(parentCustomerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        	
        	acct.ParentId = null;
        	update acct;
        	AccountTriggerHandler.run = true;
        	
        	accounts = [SELECT Id, RecordTypeId FROM Account];
        	
        	for(Account a : accounts)
        	{
        		if(a.Id == parent1.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == parent2.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        		else if(a.Id == acct.Id)
        		{
        			System.assertEquals(customerRecordType, a.RecordTypeId);
        		}
        	}
        
        Test.stopTest();
    }
    
   /* static testMethod void testTopAccountCallout() 
    {
        Account acct = DataFactory.createAccount('Account 1', false);
       	acct.iMIS_ID__c = '244654';
        insert acct;    
        
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig('Users Service', 'http://64.14.178.228/v1.6/users/', null, 0, 0);
        
        Test.startTest();
        
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse());
        	
        	AccountUtility.UpdateTop1000(acct.iMIS_ID__c, acct.ICSC_Top_Account__c);
        	        	
        Test.stopTest();    
    }
    
     static testMethod void testTopAccountCallout2() 
    {
        Account acct = DataFactory.createAccount('Account 1', false);
       	acct.iMIS_ID__c = '244654';
         acct.ICSC_Top_Account__c = true;
        insert acct;    
        
        ImisServiceConfiguration__c accountConfig = DataFactory.createImisServiceConfig('Users Service', 'http://64.14.178.228/v1.6/users/', null, 0, 0);
        
        Test.startTest();
        
        	Test.setMock(HttpCalloutMock.class, new ImisServiceMockHttpResponse());
	       
	        AccountUtility.UpdateTop1000(acct.iMIS_ID__c, acct.ICSC_Top_Account__c);
        	        	
        Test.stopTest();  
    }*/
}