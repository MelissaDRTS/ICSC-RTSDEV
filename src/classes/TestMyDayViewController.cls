@isTest
private class TestMyDayViewController 
{
    static testMethod void testViews() 
    {
        Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
        MyDayViewController controller = null;
                
       	Test.startTest();
       
       	controller = new MyDayViewController();
       
       	//Verify views' count
       	System.assertEquals(11, controller.queries.size());
       	System.assertEquals(viewMap.get('Task').size(), controller.getTaskViews().size());
       	System.assertEquals(viewMap.get('Opportunity').size(), controller.getOppViews().size());
       	System.assertEquals(viewMap.get('Account').size(), controller.getAccountViews().size());
       
       	//Verify option sorting
       	System.assertEquals('All', controller.getTaskViews()[0].getLabel());
       	System.assertEquals('All', controller.getAccountViews()[0].getLabel());
       	System.assertEquals('All', controller.getOppViews()[0].getLabel());
       
       	System.assertEquals('Subject Equals A', controller.getTaskViews()[3].getLabel());
       	System.assertEquals('Name Starts With A', controller.getOppViews()[2].getLabel());
       
       	//Verify default views
       	System.assertEquals(controller.getTaskViews()[0].getValue(), controller.taskViewId);
       	System.assertEquals(controller.getAccountViews()[0].getValue(), controller.accountViewId);
       	System.assertEquals(controller.getOppViews()[0].getValue(), controller.oppViewId);
       
       	Test.stopTest();
    }
    
    static testMethod void testTaskQueries() 
    {
    	List<Task> tasks = null;
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	List<Task> tempTasks = null;
               
       	Test.startTest();
       
       	controller = new MyDayViewController();
       	tempTasks = controller.getTasks();
       	System.assertEquals(0, controller.tasksCount);
       	
       	//verify tasks count after creating tasks
       	tasks = MyDayDataFactory.createTasks();
       	tempTasks = controller.getTasks();
       	System.assertEquals(5, tempTasks.size());
       	System.assertEquals(5, controller.tasksCount);
       
       	//Verify queries: Subject Contains A 
       	controller.taskViewId = controller.getTaskViews()[1].getValue();
       	tempTasks = controller.getTasks();
       	System.assertEquals(2, tempTasks.size());
       
       	//Verify queries: Subject Does Not Contain A
       	controller.taskViewId = controller.getTaskViews()[2].getValue();
       	tempTasks = controller.getTasks();
       	System.assertEquals(3, tempTasks.size());
       
       	//Verify queries: Subject Equals A
       	controller.taskViewId = controller.getTaskViews()[3].getValue();
       	tempTasks = controller.getTasks();
       	System.assertEquals(1, tempTasks.size());
       
       	Test.stopTest();
    }
    
    static testMethod void testTaskSort() 
    {
    	List<Task> tasks = MyDayDataFactory.createTasks();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	List<Task> tempTasks = null;
               
       	Test.startTest();
       
       	controller = new MyDayViewController();
       	tempTasks = controller.getTasks();
       	
       	//verify tasks count
       	System.assertEquals(5, tempTasks.size());
       
       	//Verify sorting Due Date/Asc
       	System.assertEquals(Date.today().addDays(-2), tempTasks[0].ActivityDate);
       	System.assertEquals(Date.today(), tempTasks[4].ActivityDate);
       
       	//Verify sorting Due Date/Desc
       	controller.taskSortDirection = 'DESC';
       	tempTasks = controller.getTasks();
       	System.assertEquals(Date.today(), tempTasks[0].ActivityDate);
       	System.assertEquals(Date.today().addDays(-2), tempTasks[4].ActivityDate);
       
       	//Verify sorting First Name/Asc
       	controller.taskSortField = 'Who.FirstName';
       	controller.taskSortDirection = 'ASC';
       	tempTasks = controller.getTasks();
       	System.assertEquals('B', tempTasks[0].Who.FirstName);
       	System.assertEquals('S', tempTasks[4].Who.FirstName);
       
       	//Verify sorting First Name/Desc
       	controller.taskSortDirection = 'DESC';
       	tempTasks = controller.getTasks();
       	System.assertEquals('S', tempTasks[0].Who.FirstName);
       	System.assertEquals('B', tempTasks[4].Who.FirstName);
       
        //Verify sorting Last Name/Asc
       	controller.taskSortField = 'Who.LastName';
       	controller.taskSortDirection = 'ASC';
       	tempTasks = controller.getTasks();
       	System.assertEquals('B', tempTasks[0].Who.LastName);
       	System.assertEquals('S', tempTasks[4].Who.LastName);
       
       	//Verify sorting Last Name/Desc
       	controller.taskSortDirection = 'DESC';
       	tempTasks = controller.getTasks();
       	System.assertEquals('S', tempTasks[0].Who.LastName);
       	System.assertEquals('B', tempTasks[4].Who.LastName);
       
        //Verify sorting Subject/Asc
       	controller.taskSortField = 'Subject';
       	controller.taskSortDirection = 'ASC';
       	tempTasks = controller.getTasks();
       	System.assertEquals('A', tempTasks[0].Subject);
       	System.assertEquals('S6', tempTasks[4].Subject);
       
       	//Verify sorting Status/Desc
       	controller.taskSortDirection = 'DESC';
       	tempTasks = controller.getTasks();
       	System.assertEquals('S6', tempTasks[0].Subject);
       	System.assertEquals('A', tempTasks[4].Subject);
       
     /*   //Verify sorting Status/Asc
       controller.taskSortField = 'Status';
       controller.taskSortDirection = 'ASC';
       tempTasks = controller.getTasks();
       System.assertEquals('In Progress', tempTasks[0].Status);
       System.assertEquals('Not Started', tempTasks[4].Status);
       
       //Verify sorting Status/Desc
       controller.taskSortDirection = 'DESC';
       tempTasks = controller.getTasks();
       System.assertEquals('Not Started', tempTasks[0].Status);
       System.assertEquals('In Progress', tempTasks[4].Status);*/
       
       	Test.stopTest();
    }
    
    static testMethod void testAccountQueries() 
    {
    	List<Account> accounts = null;
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	List<Account> tempAccounts = null;
               
       	Test.startTest();
       
       	controller = new MyDayViewController();
       	tempAccounts = controller.getAccounts();
       	
       	//verify accounts count is 0
       	System.assertEquals(0, controller.accountsCount);
       	
       	//verify accounts count after creating accounts
       	accounts = MyDayDataFactory.createAccounts();
       	tempAccounts = controller.getAccounts();
        System.assertEquals(5, tempAccounts.size());
        System.assertEquals(5, controller.accountsCount);
	          
	   	Test.stopTest();
    }
    
    static testMethod void testAccountSort() 
    {
    	List<Account> accounts = MyDayDataFactory.createAccounts();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	List<Account> tempAccounts = null;
               
       	Test.startTest();
       
       	controller = new MyDayViewController();
       	tempAccounts = controller.getAccounts();
       	
       	//verify accounts count
       	System.assertEquals(5, tempAccounts.size());
       
       	//Verify sorting Name/Asc
       	System.assertEquals('Account A', tempAccounts[0].Name);
       	System.assertEquals('Account E', tempAccounts[4].Name);
      	 
      	 
      /* //Verify sorting Status/Asc
       controller.accountSortField = 'Status';
       controller.accountSortDirection = 'ASC';
       tempAccounts = controller.getAccounts();
       System.assertEquals('Closed - Not Converted', tempAccounts[0].Status);
       System.assertEquals('Open - Not Contacted', tempAccounts[4].Status);
       
       //Verify sorting Next Step/Desc
       controller.accountSortDirection = 'DESC';
       tempAccounts = controller.getAccounts();
       System.assertEquals('Open - Not Contacted', tempAccounts[0].Status);
       System.assertEquals('Closed - Not Converted', tempAccounts[4].Status);*/
       
       	Test.stopTest();
    }
    
    static testMethod void testOppQueries() 
    {
    	List<Opportunity> opps = null;
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	List<Opportunity> tempOpps = null;
               
       	Test.startTest();
       
       	controller = new MyDayViewController();
       	tempOpps = controller.getOpps();
       	
       	//Verify opps count is 0 when there are no opps
       	System.assertEquals(0, controller.oppsCount);
       	
       	//verify opps count after creating opps
       	opps = MyDayDataFactory.createOpps();
       	tempOpps = controller.getOpps();
       	System.assertEquals(5, tempOpps.size());
       	System.assertEquals(5, controller.oppsCount);
       
       	//Verify queries: Name Ends With B Test
       	System.debug('View Name: ' + controller.getOppViews()[1].getValue());
       	controller.oppViewId = controller.getOppViews()[1].getValue();
       	tempOpps = controller.getOpps();
       	System.assertEquals(2, tempOpps.size());
      	 
       /*for(MyDayQuery q :controller.queries)
		{
			if(q.objectName == 'Opportunity')
			{				
				if(controller.oppViewId == q.viewId)
				{					
					System.assertEquals('', q.query);
					break;
				}
			}
		}*/
       
       	//Verify queries: Name Starts With A
       	controller.oppViewId = controller.getOppViews()[2].getValue();
       	tempOpps = controller.getOpps();
       	System.assertEquals(2, tempOpps.size());
       	
       	//Verify queries: Amount < 10000 and Amount > 100
       	controller.oppViewId = controller.getOppViews()[3].getValue();
       	tempOpps = controller.getOpps();
       	System.assertEquals(1, tempOpps.size());
       	
       	//Verify queries: Amount < 10000 and Name Does Not Contain N
       	controller.oppViewId = controller.getOppViews()[4].getValue();
       	tempOpps = controller.getOpps();
       	System.assertEquals(1, tempOpps.size());
       	
       	//Verify queries: My Opps
       	controller.oppViewId = controller.getOppViews()[5].getValue();
       	tempOpps = controller.getOpps();
       	System.assertEquals(5, tempOpps.size());
      	 
       	Test.stopTest();
    }
    
    static testMethod void testOppSort() 
    {
    	List<Opportunity> opps = MyDayDataFactory.createOpps();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	List<Opportunity> tempOpps = null;
               
       	Test.startTest();
       
       	controller = new MyDayViewController();
       	tempOpps = controller.getOpps();
       	
       	//verify opps count
       	System.assertEquals(5, tempOpps.size());
       
       	//Verify sorting Amount/Asc
       	System.assertEquals(100, tempOpps[0].Amount);
       	System.assertEquals(1000000, tempOpps[4].Amount);
      	 
       	//Verify sorting Amount/Desc
       	controller.oppSortDirection = 'DESC';
       	tempOpps = controller.getOpps();
       	System.assertEquals(1000000, tempOpps[0].Amount);
       	System.assertEquals(100, tempOpps[4].Amount);
       
       	//Verify sorting Close Date/Asc
       	controller.oppSortField = 'CloseDate';
       	controller.oppSortDirection = 'ASC';
       	tempOpps = controller.getOpps();
       	System.assertEquals(Date.newInstance(2014, 2, 1), tempOpps[0].CloseDate);
       	System.assertEquals(Date.newInstance(2014, 12, 1), tempOpps[4].CloseDate);
       
       	//Verify sorting Close Date/Desc
       	controller.oppSortDirection = 'DESC';
       	tempOpps = controller.getOpps();
       	System.assertEquals(Date.newInstance(2014, 12, 1), tempOpps[0].CloseDate);
       	System.assertEquals(Date.newInstance(2014, 2, 1), tempOpps[4].CloseDate);
       
       	//Verify sorting Name/Asc
       	controller.oppSortField = 'Name';
       	controller.oppSortDirection = 'ASC';
       	tempOpps = controller.getOpps();
       	System.assertEquals('A Opp', tempOpps[0].Name);
       	System.assertEquals('OppZ', tempOpps[4].Name);
      	 
       	//Verify sorting Name/Desc
       	controller.oppSortDirection = 'DESC';
       	tempOpps = controller.getOpps();
       	System.assertEquals('OppZ', tempOpps[0].Name);
       	System.assertEquals('A Opp', tempOpps[4].Name);
       
        //Verify sorting Next Step/Asc
       	controller.oppSortField = 'NextStep';
       	controller.oppSortDirection = 'ASC';
       	tempOpps = controller.getOpps();
       	System.assertEquals('A', tempOpps[0].NextStep);
       	System.assertEquals('Z', tempOpps[4].NextStep);
       
       	//Verify sorting Next Step/Desc
       	controller.oppSortDirection = 'DESC';
       	tempOpps = controller.getOpps();
       	System.assertEquals('Z', tempOpps[0].NextStep);
       	System.assertEquals('A', tempOpps[4].NextStep);
      	 
       	Test.stopTest();
    }
    
    static testMethod void testFlagging()
    {
    	List<Task> tasks = MyDayDataFactory.createTasks();
    	List<Account> accounts = MyDayDataFactory.createAccounts();
    	List<Opportunity> opps = MyDayDataFactory.createOpps();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	Task tempTask = null;
       	Account tempAccount = null;
       	Opportunity tempOpp = null;
       	
       	Test.startTest();
       	
       	controller = new MyDayViewController();
       	
       	controller.recordId = tasks[0].Id;
       	controller.flagTask();
       	tempTask = [SELECT Id, MyDayFlagged__c FROM Task where Id =: controller.recordId];
       	System.assertNotEquals(tempTask.MyDayFlagged__c, tasks[0].MyDayFlagged__c);
       	controller.flagTask();
       	tempTask = [SELECT Id, MyDayFlagged__c FROM Task where Id =: controller.recordId];
       	System.assertEquals(tempTask.MyDayFlagged__c, tasks[0].MyDayFlagged__c);
       	
       	controller.recordId = accounts[0].Id;
       	controller.flagAccount();
       	tempAccount = [SELECT Id, MyDayFlagged__c FROM Account where Id =: controller.recordId];
       	System.assertNotEquals(tempAccount.MyDayFlagged__c, accounts[0].MyDayFlagged__c);
       	controller.flagAccount();
       	tempAccount = [SELECT Id, MyDayFlagged__c FROM Account where Id =: controller.recordId];
       	System.assertEquals(tempAccount.MyDayFlagged__c, accounts[0].MyDayFlagged__c);
       	
       	controller.recordId = opps[0].Id;
       	controller.flagOpp();
       	tempOpp = [SELECT Id, MyDayFlagged__c FROM Opportunity where Id =: controller.recordId];
       	System.assertNotEquals(tempOpp.MyDayFlagged__c, opps[0].MyDayFlagged__c);
       	controller.flagOpp();
       	tempOpp = [SELECT Id, MyDayFlagged__c FROM Opportunity where Id =: controller.recordId];
       	System.assertEquals(tempOpp.MyDayFlagged__c, opps[0].MyDayFlagged__c);
       	
       	Test.stopTest();
    }
    
    static testMethod void testPaging()
    {
    	List<Task> tasks = MyDayDataFactory.createTasks();
    	List<Account> accounts = MyDayDataFactory.createAccounts();
    	List<Opportunity> opps = MyDayDataFactory.createOpps();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	Task tempTask = null;
       	Account tempAccount = null;
       	Opportunity tempOpp = null;
       	
       	Test.startTest();
       	
       	controller = new MyDayViewController();
       	
       	controller.incrementAccountPage();
       	System.assertEquals(1, controller.currentAccountPage);
       	
       	controller.decrementAccountPage();
       	System.assertEquals(1, controller.currentAccountPage);
       	
        controller.incrementOppPage();
       	System.assertEquals(1, controller.currentOppPage);
       	
       	controller.decrementOppPage();
       	System.assertEquals(1, controller.currentOppPage);
       	
       	controller.incrementTaskPage();
       	System.assertEquals(1, controller.currentTaskPage);
       	
       	controller.decrementTaskPage();
       	System.assertEquals(1, controller.currentTaskPage);
       	
       	Test.stopTest();
    }
    
    static testMethod void testResetPaging()
    {
    	List<Task> tasks = MyDayDataFactory.createTasks();
    	List<Account> accounts = MyDayDataFactory.createAccounts();
    	List<Opportunity> opps = MyDayDataFactory.createOpps();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	Task tempTask = null;
       	Account tempAccount = null;
       	Opportunity tempOpp = null;
       	
       	Test.startTest();
       	
       	controller = new MyDayViewController();
       	
       	controller.resetAccountPage();
       	System.assertEquals(1, controller.currentAccountPage);
       	
       	controller.resetOppPage();
       	System.assertEquals(1, controller.currentOppPage);
       	
       	controller.resetTaskPage();
       	System.assertEquals(1, controller.currentTaskPage);
       	
       	Test.stopTest();
    }
    
    static testMethod void testSettings()
    {
    	List<Task> tasks = MyDayDataFactory.createTasks();
    	List<Account> accounts = MyDayDataFactory.createAccounts();
    	List<Opportunity> opps = MyDayDataFactory.createOpps();
       	Map<String, List<MyDayView__c>> viewMap = MyDayDataFactory.createViews();
       	MyDayViewController controller = null;
       	Task tempTask = null;
       	Account tempAccount = null;
       	Opportunity tempOpp = null;
        MyDaySettings__c settings = null;
        
       	Test.startTest();
       	
       	controller = new MyDayViewController();
       	
       	settings = MyDaySettings__c.getInstance();
       	System.assertEquals(false, settings.HideChatter__c, controller.hideChatter);
       	
       	controller.toggleChatter();
       	settings = MyDaySettings__c.getInstance();
       	controller = new MyDayViewController();
       	System.assertEquals(true, settings.HideChatter__c, controller.hideChatter);
       	
       	controller.toggleChatter();
       	settings = MyDaySettings__c.getInstance();
       	controller = new MyDayViewController();
       	System.assertEquals(false, settings.HideChatter__c, controller.hideChatter);
       	
       	Test.stopTest();
    }
}