public with sharing class ShowPublicationUtility 
{
	private static String defaultShowPublicationName = 'Events Not in SF ';
	
	public static ID getShowEventRecordTypeId()
	{
		return Schema.SObjectType.Show_Publications__c.getRecordTypeInfosByName().get('Show/Event').getRecordTypeId();
	}
	
	/*public static Show_Publications__c getDefaultShowForBoothHistory(String year)
	{
		return  getDefaultShowForSponsorshipHistory(year);
	}
	
	public static Show_Publications__c getDefaultShowForSponsorshipHistory(String year)
	{
		List<Show_Publications__c> defaultShows = [SELECT Id FROM Show_Publications__c WHERE Name =: defaultShowPublicationName + year];
		Show_Publications__c defShow = null;
		
		if(!defaultShows.isEmpty())
		{
			defShow = defaultShows[0];
		}
		else
		{
			defShow = new Show_Publications__c(Name = defaultShowPublicationName + year, RecordTypeId = getShowEventRecordTypeId());
			insert defShow;
		}
				
		return defShow;
	}*/
}