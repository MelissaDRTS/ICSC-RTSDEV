global with sharing class CloseOldOpportunitiesBatchSchedule implements Schedulable 
{
	global void execute(SchedulableContext sc)
	{		
		Id batchInstanceId = Database.executeBatch(new CloseOldOpportunitiesBatch('Select ID from Opportunity WHERE IsClosed = false AND CloseDate < LAST_N_DAYS:60'), 200);
	}
}