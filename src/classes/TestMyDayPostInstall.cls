@isTest
private class TestMyDayPostInstall 
{
    static testMethod void testInstallScript()
    {
        MyDayPostInstall pi = new MyDayPostInstall();
        
        Test.testInstall(pi, null);
        
        Integer viewsCount = [Select count() from MyDayView__c];
        
        //System.assertEquals(23, viewsCount);
    }
}