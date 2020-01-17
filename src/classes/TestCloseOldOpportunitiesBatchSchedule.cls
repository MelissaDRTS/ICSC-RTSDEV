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
private class TestCloseOldOpportunitiesBatchSchedule 
{

    static testMethod void verifyBathIsScheduled() 
    {
      	String cron = '0 0 0 1 1 ? ' + Date.today().addYears(1).year();
    	String jobId = null;
        CronTrigger ct = null;
        CloseOldOpportunitiesBatchSchedule schedule = null;
        
        Test.startTest();
        	
	        schedule = new CloseOldOpportunitiesBatchSchedule();
	        jobId = System.schedule('Batch Schedule Test', cron, schedule);
	                
			ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	       	
	       	System.assertEquals(0, ct.TimesTriggered);
	       	
	       	System.assertEquals(Date.today().addYears(1).year() + '-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
    
    static testMethod void verifyOppIsClosed() 
    {
      	CloseOldOpportunitiesBatchSchedule schedule = null;
        Account acct = DataFactory.createAccount('Test Account', true);
        Opportunity opp1 = DataFactory.createOpp('Test opp 1', acct.Id, System.now().addDays(-61), false);
        Opportunity opp2 = DataFactory.createOpp('Test opp 1', acct.Id, System.now().addDays(-63), false);
        Opportunity opp3 = DataFactory.createOpp('Test opp 2', acct.Id, System.now().addDays(4), false);
        List<Opportunity> opps = null;
        
    	opp1.CloseDate = System.today().addDays(-61);
        opp2.CloseDate = System.today().addDays(-63);
        opp2.StageName = 'Closed Won';
        insert opp1;
        insert opp2;
        insert opp3;
        
        Test.startTest();
        	opps = [SELECT ID, IsWon, IsClosed FROM Opportunity WHERE ID =: opp1.Id OR ID =: opp2.Id];
        	
        	for(Opportunity o : opps)
        	{   
        		if(o.Id != opp2.Id)
        		{
        			System.assert(o.IsClosed == false);
        			System.assert(o.IsWon == false);
        		}
        		else
        		{
        			System.assert(o.IsWon);
        			System.assert(o.IsClosed);
        		}
        	}
        	
	       Database.executeBatch(new CloseOldOpportunitiesBatch('Select ID from Opportunity WHERE IsClosed = false AND CloseDate < LAST_N_DAYS:60'), 200);
        
        Test.stopTest();
        
        opps = [SELECT ID, IsWon, IsClosed FROM Opportunity WHERE ID =: opp1.Id OR ID =: opp2.Id OR ID =: opp3.Id];
        System.debug('Opps: ' + opps);
        	
    	for(Opportunity o : opps)
    	{
    		if(o.Id == opp1.Id)
    		{
	    		System.assert(o.IsClosed);
	    		System.assert(o.IsWon == false);
    		}
    		else if(o.Id == opp2.Id)
    		{
	    		System.assert(o.IsClosed);
	    		System.assert(o.IsWon == true);
    		}
    		else 
    		{
    			System.assert(o.IsClosed == false);
	    		System.assert(o.IsWon == false);
    		}
    	}
    
    }
}