public with sharing class MyDayUtility
{
    public static String GetNamespacePrefix()
    {
    	String namespacePrefix = '';
    	List<ApexClass> classes = [SELECT NamespacePrefix FROM ApexClass where NamespacePrefix = 'BTGMD' Limit 1];
    	
    	if(classes.size() > 0)
    	{
    		namespacePrefix = 'BTGMD__';
    	}
    	
    	return namespacePrefix;
    }	
    
    //  This is a simple quicksort algorithm to sort a SelectOption list (dropdown) 
    // by label alphabetically.
    public static List<SelectOption> SortOptionList(List<SelectOption> listToSort)
    {
    	List<SelectOption> returnList = null;
    	List<SelectOption> less = null;
        List<SelectOption> greater = null;
        SelectOption pivotValue = null;
        Integer pivot = 0;
    	
        if(listToSort == null || listToSort.size() <= 1)
            return listToSort;
        
        returnList = new List<SelectOption> ();
        less = new List<SelectOption>();
        greater = new List<SelectOption>();
        
        // save the pivot and remove it from the list
        pivotValue = listToSort[pivot];
        listToSort.remove(pivot);
        
        for(SelectOption x : listToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
            {
                less.add(x);
            }
            else if(x.getLabel() > pivotValue.getLabel())
            {
            	greater.add(x);    
            }
        }
        
        returnList.addAll(SortOptionList(less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(greater));
        
        return returnList; 
    }
    
    public static void createDefaultViews()
	{
		List<MyDayView__c> views = new List<MyDayView__c>();
		string namespacePrefix = GetNamespacePrefix();
		
		//Task views
		views.add(new MyDayView__c(Name = 'All', Object__c = 'Task'));
		views.add(new MyDayView__c(Name = 'Completed This Week', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'Status', Operation__c = 'Equals', Value__c = 'Completed',
									SecondField__c = 'RecurrenceEndDateOnly', SecondOperation__c = 'Equals', SecondValue__c = 'THIS_WEEK'));
		views.add(new MyDayView__c(Name = 'Completed Today', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'Status', Operation__c = 'Equals', Value__c = 'Completed',
									SecondField__c = 'RecurrenceEndDateOnly', SecondOperation__c = 'Equals', SecondValue__c = 'TODAY'));							
		views.add(new MyDayView__c(Name = 'Flagged', Object__c = 'Task', Field__c = namespacePrefix + 'MyDayFlagged__c', Operation__c = 'Equals', Value__c = 'True',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'My Tasks', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'Status', Operation__c = 'Not Equal To', Value__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'Next 7 Days', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'ActivityDate', Operation__c = 'Equals', Value__c = 'NEXT_N_DAYS:7',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'Overdue', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'ActivityDate', Operation__c = 'Less Than', Value__c = 'TODAY',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'This Month', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'ActivityDate', Operation__c = 'Equals', Value__c = 'THIS_MONTH',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'Today', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'ActivityDate', Operation__c = 'Equals', Value__c = 'TODAY',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'Today & Overdue', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'ActivityDate', Operation__c = 'Less or Equal', Value__c = 'TODAY',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		views.add(new MyDayView__c(Name = 'Tomorrow', Object__c = 'Task', OwnedByMe__c = true, Field__c = 'ActivityDate', Operation__c = 'Equals', Value__c = 'TOMORROW',
									SecondField__c = 'Status', SecondOperation__c = 'Not Equal To', SecondValue__c = 'Completed'));
		
		
		//Account views
		views.add(new MyDayView__c(Name = 'All', Object__c = 'Account'));							
				
		
		//Opportunity views
		views.add(new MyDayView__c(Name = 'All', Object__c = 'Opportunity'));
		views.add(new MyDayView__c(Name = 'Closing This Month', Object__c = 'Opportunity', OwnedByMe__c = true, Field__c = 'CloseDate', Operation__c = 'Equals', Value__c = 'THIS_MONTH'));
		views.add(new MyDayView__c(Name = 'Closing This Week', Object__c = 'Opportunity', OwnedByMe__c = true, Field__c = 'CloseDate', Operation__c = 'Equals', Value__c = 'THIS_WEEK'));						
		views.add(new MyDayView__c(Name = 'Flagged', Object__c = 'Opportunity', Field__c = namespacePrefix + 'MyDayFlagged__c', Operation__c = 'Equals', Value__c = 'TRUE'));
		views.add(new MyDayView__c(Name = 'My Opportunities', Object__c = 'Opportunity', OwnedByMe__c = true));
		views.add(new MyDayView__c(Name = 'My Open Opportunities', Object__c = 'Opportunity', OwnedByMe__c = true, Field__c = 'IsClosed', Operation__c = 'Equals', Value__c = 'False'));	
		
		insert views;
	}
}