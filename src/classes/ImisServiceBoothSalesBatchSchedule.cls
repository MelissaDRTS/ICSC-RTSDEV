global with sharing class ImisServiceBoothSalesBatchSchedule implements Schedulable 
{
	@TestVisible private Boolean isTest{get;set;}
	
	global void execute(SchedulableContext sc)
	{		
		Id batchInstanceId = Database.executeBatch(new ImisServiceBoothSalesBatch('Select ID from User ' + (isTest != null && isTest ? ' LIMIT 1' : ' LIMIT 10'), isTest), 1);
	}
}