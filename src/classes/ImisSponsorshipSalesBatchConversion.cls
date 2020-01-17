global class ImisSponsorshipSalesBatchConversion implements Database.Batchable<sObject>, Database.Stateful {
	
	List<iMIS_Sponsorship_Sales__c> updatedRecords{get;set;}
	List<iMIS_Sponsorship_Sales__c> notUpdatedRecords{get;set;}

	global ImisSponsorshipSalesBatchConversion() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'Select Id, Name, Transaction_Date__c, Account_Name__c'
			+ ', Cost__c, Quantity__c, Sale_Type__c, Show__c, Year__c'
			+ ' from iMIS_Sponsorship_Sales__c' 
			+ ' where Opportunity__c = null and (Year__c = \'2015\' or Year__c = \'2016\')'
			+ ' order by Account_Name__c'; //reduce lock errors
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('ImisSponsorshipSalesBatchConversion started on '+scope.size()+' records.');
   		List<iMIS_Sponsorship_Sales__c> records = scope;
   		//get the map 
   		Map<Id,String> accountIdToBillingStateMap = ImisSponsorshipSalesConverter.getAccountIdToBillingStateMap(scope);
		//process the records
		ImisSponsorshipSalesConverter.insertOpportunitiesWithLineItems(records,accountIdToBillingStateMap);
		//keep the results for finish() call
		updatedRecords = [Select Id, Name from iMIS_Sponsorship_Sales__c where Opportunity__c != null and Id in :records];
		notUpdatedRecords = [Select Id, Name from iMIS_Sponsorship_Sales__c where Opportunity__c = null and Id in :records];
	}
	
	global void finish(Database.BatchableContext BC){
	    // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
	    // Query the AsyncApexJob object to retrieve the current job's information.
	    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
	      TotalJobItems, CreatedBy.Email
	      FROM AsyncApexJob WHERE Id =
	      :BC.getJobId()];
	    String logHeader = 'ImisSponsorshipSalesBatchConversion ' + a.Status;
	    String logBody = 'The batch Apex job processed ' + a.TotalJobItems +
	   		' batches with '+ a.NumberOfErrors + ' failures. ';
	    System.debug(logHeader+' -- '+logBody);
	    if (false){
		    // Send an email to the Apex job's submitter notifying of job completion.
		    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    String[] toAddresses = new String[] {'icsc@rtslabs.com'};
		    mail.setToAddresses(toAddresses);
		    mail.setSubject(logHeader);
		    mail.setPlainTextBody(logBody);
		   		//+ 'Job updated '
		    	//+ updatedRecords.size()+'/'+(notUpdatedRecords.size()+updatedRecords.size())+' records.');
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	
}