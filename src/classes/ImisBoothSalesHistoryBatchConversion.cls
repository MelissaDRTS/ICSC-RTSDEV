global class ImisBoothSalesHistoryBatchConversion implements Database.Batchable<sObject>, Database.Stateful {
	
	List<iMis_Booth__c> updatedRecords{get;set;}
	List<iMis_Booth__c> notUpdatedRecords{get;set;}

	global ImisBoothSalesHistoryBatchConversion() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'Select Id, Name, Transaction_Date__c, Account_Name__c, Booth_Contact__c, Booth_Contact_Email__c'
			+ ', Cost__c, Quantity__c, Type_of_Booth_Purchased__c, Sale_Type__c, Show__c, Year__c'
			+ ' from iMis_Booth__c' 
			+ ' where Opportunity__c = null and (Year__c = \'2015\' or Year__c = \'2016\')'
			+ ' order by Account_Name__c'; //reduce lock errors
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('ImisBoothSalesHistoryBatchConversion started on '+scope.size()+' records.');
   		List<iMis_Booth__c> records = scope;
   		//get the map 
   		Map<Id,String> accountIdToBillingStateMap = ImisBoothSalesHistoryConverter.getAccountIdToBillingStateMap(scope);
		//process the records
		ImisBoothSalesHistoryConverter.insertOpportunitiesWithLineItems(records,accountIdToBillingStateMap);
		//keep the results for finish() call
		updatedRecords = [Select Id, Name from iMis_Booth__c where Opportunity__c != null and Id in :records];
		notUpdatedRecords = [Select Id, Name from iMis_Booth__c where Opportunity__c = null and Id in :records];
	}
	
	global void finish(Database.BatchableContext BC){
	    // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
	    // Query the AsyncApexJob object to retrieve the current job's information.
	    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
	      TotalJobItems, CreatedBy.Email
	      FROM AsyncApexJob WHERE Id =
	      :BC.getJobId()];
	    // Send an email to the Apex job's submitter notifying of job completion.
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {'icsc@rtslabs.com'};
	    mail.setToAddresses(toAddresses);
	    mail.setSubject('iMISBoothSalesHistoryBatchConversion ' + a.Status);
	    mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
	   		' batches with '+ a.NumberOfErrors + ' failures. ');
	   		//+ 'Job updated '
	    	//+ updatedRecords.size()+'/'+(notUpdatedRecords.size()+updatedRecords.size())+' records.');
	    if (Test.isRunningTest() == false){
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	
}