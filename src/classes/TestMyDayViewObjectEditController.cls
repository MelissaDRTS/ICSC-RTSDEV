@isTest
private class TestMyDayViewObjectEditController 
{

 	static testMethod void testViewValidation() 
    {
    	MyDayViewObjectEditController controller = null;
   		PageReference pageRef = Page.MyDayViewObjectEdit;
    	Test.setCurrentPage(pageRef);        
    	//pageRef.getParameters().put('id', );
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(new MyDayView__c());
    	MyDayView__c temp = null;
    	
    	controller = new MyDayViewObjectEditController(ctrl);    	
    	controller.save();
    	
    	System.assert(ApexPages.hasMessages());
    	System.assertEquals('Name is required.', ApexPages.getMessages()[0].getSummary());
    	
    	controller.view.Name = 'Test View';
    	controller.view.Object__c = '';
    	controller.save();
    	
    	System.assert(ApexPages.hasMessages());
    	System.assertEquals('Object is required.', ApexPages.getMessages()[1].getSummary());
    	
    	controller.view.Name = 'Test View';
    	controller.view.Object__c = 'Account';
    	controller.view.Field__c = 'Name';
    	controller.save();
    	
    	System.assert(ApexPages.hasMessages());
    	System.assertEquals('All primary fields are required if a primary field is specified.', ApexPages.getMessages()[2].getSummary());
    	
    	controller.view.Name = 'Test View';
    	controller.view.Object__c = 'Account';
    	controller.view.Field__c = '';
    	controller.view.SecondField__c = 'Name';
    	controller.saveAndNew();
    	
    	System.assert(ApexPages.hasMessages());
    	System.assertEquals('All secondary fields are required if a secondary field is specified.', ApexPages.getMessages()[3].getSummary());
    	
    	controller.cancel();
    }
    
    static testMethod void testAccountView() 
    {
    	MyDayViewObjectEditController controller = null;
   		PageReference pageRef = Page.MyDayViewObjectEdit;
    	Test.setCurrentPage(pageRef);        
    	//pageRef.getParameters().put('id', );
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(new MyDayView__c());
    	MyDayView__c temp = null;
    	
    	controller = new MyDayViewObjectEditController(ctrl);
    	
    	System.assertEquals(0, controller.getObjectFields().size());
    	
    	controller.view.Name = 'Test View';
    	controller.view.Object__c = 'Account';
    	controller.view.Private__c = true;
    	controller.save();
    	
    	//Verify view was saved
    	System.assertNotEquals(null, controller.view.Id);
    	
    	//Verify edit
    	temp = controller.view;
    	pageRef.getParameters().put('id', temp.Id);
    	ctrl = new ApexPages.StandardController(new MyDayView__c());
    	controller = new MyDayViewObjectEditController(ctrl);    	
    	System.assertEquals(temp.Id, controller.view.Id);
    	   	
    	
    	controller.view.Name = 'Test View Edit';
    	Test.setCurrentPage(controller.saveAndNew());
    	ctrl = new ApexPages.StandardController(new MyDayView__c());
    	controller = new MyDayViewObjectEditController(ctrl);
    	
    	System.AssertEquals(null, controller.view.id);
    }
    
   
    static testMethod void testCloneAccountView() 
    {
    	MyDayViewObjectEditController controller = null;
   		PageReference pageRef = Page.MyDayViewObjectEdit;
   		MyDayView__c view = new MyDayView__c(Name='Test', Object__c='Account');
   		insert view;
   		
    	Test.setCurrentPage(pageRef);        
    	pageRef.getParameters().put('id', view.Id);
    	pageRef.getParameters().put('clone', '1');
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(new MyDayView__c());
    	    	    	
    	//Verify clone
    	ctrl = new ApexPages.StandardController(new MyDayView__c());
    	controller = new MyDayViewObjectEditController(ctrl);    	
    	System.assertNotEquals(view.Id, controller.view.Id);
    	System.assertEquals(view.Name, controller.view.Name);
    	
    	System.assertEquals(controller.getObjectFields().size(), controller.accountFields.size());
    }
    
    static testMethod void testCloneTaskView() 
    {
    	MyDayViewObjectEditController controller = null;
   		PageReference pageRef = Page.MyDayViewObjectEdit;
   		MyDayView__c view = new MyDayView__c(Name='Test', Object__c='Task');
   		insert view;
   		
    	Test.setCurrentPage(pageRef);        
    	pageRef.getParameters().put('id', view.Id);
    	pageRef.getParameters().put('clone', '1');
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(new MyDayView__c());
    	    	    	
    	//Verify clone
    	ctrl = new ApexPages.StandardController(new MyDayView__c());
    	controller = new MyDayViewObjectEditController(ctrl);    	
    	System.assertNotEquals(view.Id, controller.view.Id);
    	System.assertEquals(view.Name, controller.view.Name);
    	
    	System.assertEquals(controller.getObjectFields().size(), controller.taskFields.size());
    }
    
    static testMethod void testCloneOppView() 
    {
    	MyDayViewObjectEditController controller = null;
   		PageReference pageRef = Page.MyDayViewObjectEdit;
   		MyDayView__c view = new MyDayView__c(Name='Test', Object__c='Opportunity');
   		insert view;
   		
    	Test.setCurrentPage(pageRef);        
    	pageRef.getParameters().put('id', view.Id);
    	pageRef.getParameters().put('clone', '1');
    	ApexPages.StandardController ctrl = new ApexPages.StandardController(new MyDayView__c());
    	    	    	
    	//Verify clone
    	ctrl = new ApexPages.StandardController(new MyDayView__c());
    	controller = new MyDayViewObjectEditController(ctrl);    	
    	System.assertNotEquals(view.Id, controller.view.Id);
    	System.assertEquals(view.Name, controller.view.Name);
    	
    	System.assertEquals(controller.getObjectFields().size(), controller.oppFields.size());
    }
}