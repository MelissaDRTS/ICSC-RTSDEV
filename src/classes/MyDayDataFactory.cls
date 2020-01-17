@isTest
public class MyDayDataFactory 
{
	public static List<Account> createAccounts()
	{
		List<Account> accounts = MyDaySmartFactory.createSObjectList('Account', false, 5);
		
		accounts[0].Name = 'Account A';
		accounts[1].Name = 'Account B';
		accounts[2].Name = 'Account C';
		accounts[3].Name = 'Account D';
		accounts[4].Name = 'Account E';
				
		insert accounts;
		
		return accounts;
	}
	
	public static List<Task> createTasks()
	{
		List<Task> tasks = MyDaySmartFactory.createSObjectList('Task', false, 5);
		List<Contact> contacts = MyDaySmartFactory.createSObjectList('Contact', false, 5);
		
		contacts[0].LastName = 'S';
		contacts[0].FirstName = 'S';
		
		contacts[1].LastName = 'B';
		contacts[1].FirstName = 'B';
		
		contacts[2].LastName = 'F';
		contacts[2].FirstName = 'F';
		
		contacts[3].LastName = 'C';
		contacts[3].FirstName = 'C';
		
		contacts[4].LastName = 'D';
		contacts[4].FirstName = 'D';
		
		insert contacts;
		
		tasks[0].ActivityDate = Date.today().addDays(-1);
		tasks[0].WhoId = contacts[0].Id;
		//tasks[0].Status = 'In Progress';
		tasks[0].Subject = 'AS4';
       	
       	tasks[1].ActivityDate = Date.today().addDays(-2);
       	tasks[1].WhoId = contacts[1].Id;
		//tasks[1].Status = 'In Progress';
		tasks[1].Subject = 'S6';
		
       	tasks[2].ActivityDate = Date.today();
       	tasks[2].WhoId = contacts[2].Id;
		//tasks[2].Status = 'In Progress';
		tasks[2].Subject = 'A';
		
       	tasks[3].ActivityDate = Date.today();
       	tasks[3].WhoId = contacts[3].Id;
		//tasks[3].Status = 'Not Started';
		tasks[3].Subject = 'S1';
		
       	tasks[4].ActivityDate = Date.today();
		tasks[4].WhoId = contacts[4].Id;
		//tasks[4].Status = 'In Progress';
		tasks[4].Subject = 'S34';
		
		insert tasks;
		
		return tasks;
	}
	
	public static List<Opportunity> createOpps()
	{
		List<Opportunity> opps = MyDaySmartFactory.createSObjectList('Opportunity', false, 5);
		
		opps[0].Name = 'A Opp';
       	opps[0].Amount = 1000;
       	opps[0].CloseDate = Date.newInstance(2014, 12, 1);
       	opps[0].NextStep = 'Z';
       	
       	opps[1].Name = 'Another opp';
       	opps[1].Amount = 100;
       	opps[1].CloseDate = Date.newInstance(2014, 3, 1);
       	opps[1].NextStep = 'X';
       	
       	opps[2].Name = 'Opp B Test';
       	opps[2].Amount = 10000;
       	opps[2].CloseDate = Date.newInstance(2014, 2, 1);
       	opps[2].NextStep = 'A';
       	
       	opps[3].Name = 'OppZ';
       	opps[3].Amount = 1000000;
       	opps[3].CloseDate = Date.newInstance(2014, 8, 1);
       	opps[3].NextStep = 'B';
       	
       	opps[4].Name = 'OppB Test';
       	opps[4].Amount = 100000;
       	opps[4].CloseDate = Date.newInstance(2014, 5, 1);
       	opps[4].NextStep = 'C';
       	
       	insert opps;
       	
		return opps;
	}
	
	public static Map<String, List<MyDayView__c>> createViews()
	{
		Map<String, List<MyDayView__c>> viewMap = new Map<String, List<MyDayView__c>>();
		List<MyDayView__c> views = null;
		
		//Task views
		views = new List<MyDayView__c>();
		views.add(new MyDayView__c(Name = 'All', Object__c = 'Task'));
		views.add(new MyDayView__c(Name = 'Subject Contains A', Object__c = 'Task', Field__c = 'Subject', Operation__c = 'Contains', Value__c = 'A'));
		views.add(new MyDayView__c(Name = 'Subject Does Not Contain A', Object__c = 'Task', Field__c = 'Subject', Operation__c = 'Does Not Contain', Value__c = 'A'));
		views.add(new MyDayView__c(Name = 'Subject Equals A', Object__c = 'Task', Field__c = 'Subject', Operation__c = 'Equals', Value__c = 'A'));
		insert views;
		viewMap.put('Task', views);
		
		//Account views
		views = new List<MyDayView__c>();
		views.add(new MyDayView__c(Name = 'All', Object__c = 'Account'));
		insert views;
		viewMap.put('Account', views);
		
		//Opportunity views
		views = new List<MyDayView__c>();
		views.add(new MyDayView__c(Name = 'All', Object__c = 'Opportunity'));		
		views.add(new MyDayView__c(Name = 'Name Starts With A', Object__c = 'Opportunity', Field__c = 'Name', Operation__c = 'Starts With', Value__c = 'A'));
		views.add(new MyDayView__c(Name = 'Name Ends With B Test', Object__c = 'Opportunity', Field__c = 'Name', Operation__c = 'Ends With', Value__c = 'B Test'));
		views.add(new MyDayView__c(Name = 'x- Amount < 10000 and Amount > 100', Object__c = 'Opportunity', Field__c = 'Amount', Operation__c = 'Less Than', Value__c = '10000', 
										SecondField__c = 'Amount', SecondOperation__c = 'Greater Than', SecondValue__c = '100'));
		views.add(new MyDayView__c(Name = 'y - Amount < 10000 and Name Does Not Contain N', Object__c = 'Opportunity', Field__c = 'Amount', Operation__c = 'Less Than', Value__c = '10000', 
										SecondField__c = 'Name', SecondOperation__c = 'Does Not Contain', SecondValue__c = 'N'));
		views.add(new MyDayView__c(Name = 'z - My Opps', Object__c = 'Opportunity', OwnedByMe__c = true));
		insert views;
		viewMap.put('Opportunity', views);
		
		return viewMap;
	}
}