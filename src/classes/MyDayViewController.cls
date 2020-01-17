public with sharing class MyDayViewController 
{
	public Integer tasksCount {get;set;}
	public Integer accountsCount {get;set;}
	public Integer oppsCount {get;set;}	
	public List<MyDayQuery> queries{get;set;}
	public ID taskViewId {get;set;}
	public ID accountViewId {get;set;}
	public ID oppViewId {get;set;}
	
	public String taskSortField {get;set;}
	public String taskSortDirection{get;set;}
	public String accountSortField {get;set;}
	public String accountSortDirection{get;set;}
	public String oppSortField {get;set;}
	public String oppSortDirection{get;set;}
	public String namespacePrefix{get;set;}
    public ID recordId {get;set;}
    public Integer taskPages {get;set;}
    public Integer currentTaskPage {get;set;}
    public Integer accountPages {get;set;}
    public Integer currentAccountPage {get;set;}
    public Integer oppPages {get;set;}
    public Integer currentOppPage {get;set;}
    public static final Integer PAGE_SIZE = 50;
    public Boolean hideChatter{get;set;}
    
    public String firstAccountField{get;set;}
	
	public MyDayViewController()
	{		
		namespacePrefix = MyDayUtility.GetNamespacePrefix();
		
		this.taskSortField = 'ActivityDate';
	    this.taskSortDirection = 'ASC';
	    this.oppSortField = 'Amount';
	    this.oppSortDirection = 'ASC';
	    this.accountSortField = 'Name';
	    this.accountSortDirection = 'ASC';
		this.currentAccountPage = 1;
		this.currentOppPage = 1;
		this.currentTaskPage = 1;
		this.tasksCount = 0;
		this.oppsCount = 0;
		this.accountsCount = 0;
				
		this.queries = MyDayQuery.getAll(UserInfo.getUserId(), namespacePrefix);
		
		
		this.firstAccountField = getAccountFields()[0].FieldPath;
		
		loadSettings();
		
		if(this.accountViewId == null || this.oppViewId == null || this.taskViewId == null)
		{
			for(MyDayQuery q :this.queries)
			{
				if(q.objectName == 'Opportunity')
				{
					if(this.oppViewId == null)
					{
						this.oppViewId = q.viewId;
					}				
				}
				else if(q.objectName == 'Account')
				{
					if(this.accountViewId == null)
					{
						this.accountViewId = q.viewId;
					}
				}
				else if(q.objectName == 'Task')
				{					
					if(this.taskViewId == null)
					{
						this.taskViewId = q.viewId;
					}
				}
				
				if(this.oppViewId != null && this.accountViewId != null && this.taskViewId != null)
				{
					break;
				}
			}
		}
	}
	
	private void loadSettings()
	{
		MyDaySettings__c settings = null;
        
        //Custom Settings
        settings = MyDaySettings__c.getInstance();
        
        if(settings != null )
        {
        	hideChatter = settings.HideChatter__c;
        	
            if(settings.LeadSortDirection__c != null && settings.LeadSortDirection__c != '')
            {                       
                    this.accountSortDirection = settings.LeadSortDirection__c;
            }
            
            if(settings.LeadSortField__c != null && settings.LeadSortField__c != '')
            {                       
                    this.accountSortField = settings.LeadSortField__c;
            }
            
            if(settings.LeadViewId__c != null && settings.LeadViewId__c != '')
            {                       
                    this.accountViewId = settings.LeadViewId__c;
            }
            
            if(settings.OpportunitySortDirection__c != null && settings.OpportunitySortDirection__c != '')
            {                       
                    this.oppSortDirection = settings.OpportunitySortDirection__c;
            }
            
            if(settings.OpportunitySortField__c != null && settings.OpportunitySortField__c != '')
            {                       
                    this.oppSortField = settings.OpportunitySortField__c;
            }
            
            if(settings.OpportunityViewId__c != null && settings.OpportunityViewId__c != '')
            {                       
                    this.oppViewId = settings.OpportunityViewId__c;
            }
            
            if(settings.TaskSortDirection__c != null && settings.TaskSortDirection__c != '')
            {                       
                    this.taskSortDirection = settings.TaskSortDirection__c;
            }
            
            if(settings.TaskSortField__c != null && settings.TaskSortField__c != '')
            {                       
                    this.taskSortField = settings.TaskSortField__c;
            }
            
            if(settings.TaskViewId__c != null && settings.TaskViewId__c != '')
            {                       
                    this.taskViewId = settings.TaskViewId__c;
            }
        }
	}
	
	public void toggleChatter()
	{
		this.hideChatter = !this.hideChatter;
		SaveSettings();	
	}
	
	private void SaveSettings()
	{
		MyDaySettings__c settings = MyDaySettings__c.getInstance();
        
        settings.LeadSortDirection__c = this.accountSortDirection;
        settings.LeadSortField__c = this.accountSortField;
        settings.LeadViewId__c = this.accountViewId;
        settings.OpportunitySortDirection__c = this.oppSortDirection;
        settings.OpportunitySortField__c = this.oppSortField;
        settings.OpportunityViewId__c = this.oppViewId;
        settings.TaskSortDirection__c = this.taskSortDirection;
        settings.TaskSortField__c = this.taskSortField;
        settings.TaskViewId__c = this.taskViewId;           
        settings.HideChatter__c = this.hideChatter;
         
        upsert settings;            
	}
	
	public String getObjectPrefix()
	{
		Schema.DescribeSObjectResult r = MyDayView__c.sObjectType.getDescribe();
		
		return r.getKeyPrefix();
	}
	
	public List<Schema.FieldSetMember> getAccountFields()
	{
		return MyDayQuery.getAccountFields();
	}
	
	public List<SelectOption> getAccountSortOptions() 
	{
		List<SelectOption> opts = new List<SelectOption>();
		
		for(Schema.FieldSetMember f :getAccountFields()) 
		{
       		opts.add(new SelectOption(f.FieldPath,f.Label));
		}
			
		opts = MyDayUtility.SortOptionList(opts);
		
		return opts;
	}
	
	public List<SelectOption> getAccountViews() 
	{
		List<SelectOption> opts = new List<SelectOption>();
		
		if(this.queries != null)
		{
			for(MyDayQuery q :this.queries)
			{				
				if(q.objectName == 'Account')
				{
					opts.add(new SelectOption(q.viewId,q.viewName));
				}				
			}
			
			opts = MyDayUtility.SortOptionList(opts);
		}
		
		return opts;
	}
	
	public List<SelectOption> getOppViews() 
	{
		List<SelectOption> opts = new List<SelectOption>();
		
		if(this.queries != null)
		{
			for(MyDayQuery q :this.queries)
			{
				if(q.objectName == 'Opportunity')
				{
					opts.add(new SelectOption(q.viewId,q.viewName));
				}
			}
			
			opts = MyDayUtility.SortOptionList(opts);
		}
		
		return opts;
	}
	
	public List<SelectOption> getTaskViews() 
	{
		List<SelectOption> opts = new List<SelectOption>();
		
		if(this.queries != null)
		{
			for(MyDayQuery q :this.queries)
			{
				if(q.objectName == 'Task')
				{	
					opts.add(new SelectOption(q.viewId,q.viewName));
				}
			}
			
			opts = MyDayUtility.SortOptionList(opts);
		}
		
		return opts;
	}
	
	public List<Task> getTasks()
	{
		List<Task> tasks = null;
		
		for(MyDayQuery q :this.queries)
		{
			if(q.objectName == 'Task')
			{				
				if(this.taskViewId == q.viewId)
				{		
					this.tasksCount = Database.countQuery(q.query.replaceFirst('SELECT.*FROM','SELECT count() FROM') + ' LIMIT 10000');
					
					if(this.tasksCount > 0)
					{
						this.taskPages = tasksCount / PAGE_SIZE + (Math.mod(tasksCount,PAGE_SIZE) > 0 ? 1 : 0); 
					 	tasks = Database.query(q.query + ' ORDER BY ' + String.escapeSingleQuotes(this.taskSortField) + ' ' + String.escapeSingleQuotes(this.taskSortDirection) + ' LIMIT 50 OFFSET ' + String.valueOf((this.currentTaskPage - 1) * 50));
					}
					 
					break;
				}
			}
		}
				
		return tasks;
	}
	
	public List<Account> getAccounts()
	{
		List<Account> accounts = null;
		
		for(MyDayQuery q :this.queries)
		{
			if(q.objectName == 'Account')
			{				
				if(this.accountViewId == q.viewId)
				{					
					this.accountsCount = Database.countQuery(q.query.replaceFirst('SELECT.*FROM','SELECT count() FROM') + ' LIMIT 10000');
					
					if(this.accountsCount > 0)
					{
						this.accountPages = accountsCount / PAGE_SIZE + (Math.mod(accountsCount,PAGE_SIZE) > 0 ? 1 : 0); 
					 	accounts = Database.query(q.query + ' ORDER BY ' + String.escapeSingleQuotes(this.accountSortField) + ' ' + String.escapeSingleQuotes(this.accountSortDirection) + ' LIMIT 50 OFFSET ' + String.valueOf((this.currentAccountPage - 1) * 50));
					}
					
					break;
				}
			}
		}
		
		return accounts;
	}
	
	public List<Opportunity> getOpps()
	{
		List<Opportunity> opps = null;
		
		for(MyDayQuery q :this.queries)
		{
			if(q.objectName == 'Opportunity')
			{				
				if(this.oppViewId == q.viewId)
				{					
					this.oppsCount = Database.countQuery(q.query.replaceFirst('SELECT.*FROM','SELECT count() FROM') + ' LIMIT 10000');
					
					if(this.oppsCount > 0)
					{
						this.oppPages = oppsCount / PAGE_SIZE + (Math.mod(oppsCount,PAGE_SIZE) > 0 ? 1 : 0); 
					 	opps = Database.query(q.query + ' ORDER BY ' + String.escapeSingleQuotes(this.oppSortField) + ' ' + String.escapeSingleQuotes(this.oppSortDirection) + ' LIMIT 50 OFFSET ' + String.valueOf((this.currentOppPage - 1) * 50));
					}
					break;
				}
			}
		}
		
		return opps;
	}
	
	public void flagTask()
	{
		Task t = [SELECT Id, MyDayFlagged__c FROM Task where Id =: recordId];
		
		t.MyDayFlagged__c = !t.MyDayFlagged__c;
		
		update t;
	}
	
	public void flagAccount()
	{
		Account l = [SELECT Id, MyDayFlagged__c FROM Account where Id =: recordId];
		
		l.MyDayFlagged__c = !l.MyDayFlagged__c;
		
		update l;
	}
	
	public void flagOpp()
	{
		Opportunity o = [SELECT Id, MyDayFlagged__c FROM Opportunity where Id =: recordId];
		
		o.MyDayFlagged__c = !o.MyDayFlagged__c;
		
		update o;
	}
	
	public void decrementTaskPage()
	{
		if(this.currentTaskPage > 1)
		{
			this.currentTaskPage -= 1;
		}
	}
	
	public void incrementTaskPage()
	{
		if(this.currentTaskPage < this.taskPages)
		{
			this.currentTaskPage += 1;
		}
	}
	
	public void decrementAccountPage()
	{
		if(this.currentAccountPage > 1)
		{
			this.currentAccountPage -= 1;
		}
	}
	
	public void incrementAccountPage()
	{
		if(this.currentAccountPage < this.accountPages)
		{
			this.currentAccountPage += 1;
		}
	}
	
	public void decrementOppPage()
	{
		if(this.currentOppPage > 1)
		{
			this.currentOppPage -= 1;
		}
	}
	
	public void incrementOppPage()
	{
		if(this.currentOppPage < this.oppPages)
		{
			this.currentOppPage += 1;
		}
	}
	
	public void resetTaskPage()
	{
		this.currentTaskPage = 1;
		
		SaveSettings();
	}
	
	public void resetAccountPage()
	{
		this.currentAccountPage = 1;		
		
		SaveSettings();
	}
	
	public void resetOppPage()
	{
		this.currentOppPage = 1;
		
		SaveSettings();
	}
}