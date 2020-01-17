global class MyDayPostInstall implements InstallHandler
{
	global void onInstall(InstallContext context) 
	{
	    if(context.previousVersion() == null)
	    {
	    	List<MyDayView__c> views = [Select ID from MyDayView__c LIMIT 2];
	    	
	    	if(views == null || views.size() <= 0)
	    	{
	    		MyDayUtility.createDefaultViews();
	    	}
	    }
    }
}