@isTest
private class TestMyDayUtility {

    static testMethod void testDefaultViews() 
    {
    	Integer viewsCount = [Select count() from MyDayView__c];
    	
    	System.assertEquals(0, viewsCount);
        
        MyDayUtility.createDefaultViews();
        viewsCount = [Select count() from MyDayView__c];
        
        System.assertEquals(18, viewsCount);
    }
}