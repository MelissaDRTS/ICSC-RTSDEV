public class ShowpubRedirectController {
    ApexPages.StandardController stdCon{get;set;}
    public List<Invoice__c> invoicesForEmail{get;set;}
    public boolean hNext{get{return hasNext();}set;}
    public boolean hPrev{get{return hasPrev();}set;}
    public Integer currentPage{get;set;}
    private Integer lastPage{get;set;}
    public String filter{get;set;}
    public List<SelectOption> filterOptions {get{
            if(filterOptions == null){
                filterOptions = new List<SelectOption>();
                filterOptions.add(new SelectOption('None', 'None'));
                filterOptions.add(new SelectOption('Both', 'Both'));
                filterOptions.add(new SelectOption('Paper', 'Paper'));
                filterOptions.add(new SelectOption('Digital', 'Digital'));
            }
            return filterOptions;

        }
        set;}
    public List<Invoice__c> invoicesForDisplay{get;set;}
    private Map<Integer, Set<Id>> pages;
    private static Integer PAGE_SIZE = 50;
    public String emailFieldName{get{return 'Conga_Invoice__c';}} 
    public String downloadFieldName{get{return 'Conga_Download_Invoices__c';}}
    public String printIdArray{get;set;}
    public String emailIdArray{get;set;}
	public ShowpubRedirectController(ApexPages.StandardController sC){
        stdCon = sc;
        invoicesForEmail = [Select Id, Invoice_Preference__c from Invoice__c where Product__r.Show_Event_Publication__c = :stdCon.getId() and Authorized_For_Printing__c = true];
        pages = new Map<Integer, Set<Id>>();
        printIdArray = '';
        emailIdArray = '';
        filter = 'None';
        /*
        for (Invoice__c i : invoicesForEmail){
            printIdArray += i.Id+',';
            if (i.Invoice_Preference__c == 'Both' ||
                i.Invoice_Preference__c == 'Digital'){
                emailIdArray += i.Id+',';
            }
        }
        System.debug('Print array: ' + printIdArray);
        System.debug('Email array: ' + emailIdArray);*/
        boolean done = false;
        Integer i = 0;
        invoicesForDisplay = new List<Invoice__c>();
        if(!invoicesForEmail.isEmpty()){
            while(!done){
                Set<Id> page = new Set<Id>();
                for(Integer j= i* PAGE_SIZE; j<(i*PAGE_SIZE + PAGE_SIZE) && j<invoicesForEmail.size(); j++){
                    page.add(invoicesForEmail.get(j).id);
                    if(j == invoicesForEmail.size() - 1)
                        done = true;
                }
                pages.put(i, page);
                if(done)
                    break;
                else
                    i++;
                
            }
            currentPage = 0;
            lastPage = i;
            updatePage(currentPage);
            hNext = hasNext();
            hPrev = hasPrev();
            getPageOptions();
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No invoices authorized for printing were found for this show/publication.'));
            
        }
        /*
        if (emailIdArray.length() > 0) emailIdArray = emailIdArray.substring(0,emailIdArray.length()-1); //trim trailing comma
        if (printIdArray.length() > 0) printIdArray = printIdArray.substring(0,printIdArray.length()-1); //trim trailing comma
	    */
    }
    public boolean hasError{
        get{
            hasError = ApexPages.hasMessages();
            return hasError;
        }
        set;
    }
    public void changeFilter(){
        if(!filter.equals('None')){
            invoicesForEmail = [Select Id, Invoice_Preference__c from Invoice__c where 
            Product__r.Show_Event_Publication__c = :stdCon.getId() and Authorized_For_Printing__c = true
            and Invoice_Preference__c = :filter];
        }
        else{
            invoicesForEmail = [Select Id, Invoice_Preference__c from Invoice__c where Product__r.SHow_Event_Publication__c = :stdCon.getId()
            and Authorized_For_Printing__c = true];
        }
        boolean done = false;
        Integer i = 0;
        pages.clear();
        invoicesForDisplay = new List<Invoice__c>();
        if(!invoicesForEmail.isEmpty()){
            while(!done){
                Set<Id> page = new Set<Id>();
                for(Integer j= i* PAGE_SIZE; j<(i*PAGE_SIZE + PAGE_SIZE) && j<invoicesForEmail.size(); j++){
                    page.add(invoicesForEmail.get(j).id);
                    if(j == invoicesForEmail.size() - 1)
                        done = true;
                }
                pages.put(i, page);
                if(done)
                    break;
                else
                    i++;
                
            }
            currentPage = 0;
            lastPage = i;
            updatePage(currentPage);
            hNext = hasNext();
            hPrev = hasPrev();
            getPageOptions();
        }

    }
    public void updatePage(Integer newPage){
        invoicesForDisplay = [Select Id, Name, Product__r.Order.Account.Invoice_Receipt_Address__c, Invoice_Preference__c, Product__r.Invoice_Receipt_Notes__c 
                              from Invoice__c 
                              where Product__r.Show_Event_Publication__c = :stdCon.getId() and id in: pages.get(newPage) and Authorized_For_Printing__c = true
                             order by Name];
        emailIdArray = '';
        printIdArray = '';
        for (Invoice__c i : invoicesForDisplay){
            printIdArray += i.Id+',';
            if (i.Invoice_Preference__c == 'Both' ||
                i.Invoice_Preference__c == 'Digital'){
                emailIdArray += i.Id+',';
            }
        }
        System.debug('Print array: ' + printIdArray);
        System.debug('Email array: ' + emailIdArray);
        if (emailIdArray.length() > 0) emailIdArray = emailIdArray.substring(0,emailIdArray.length()-1); //trim trailing comma
        if (printIdArray.length() > 0) printIdArray = printIdArray.substring(0,printIdArray.length()-1); //trim trailing comma
        pageSelected = String.valueOf(newPage);
        
    }
    public void last(){
        currentPage = lastPage;
        hNext = hasNext();
        hPrev = hasPrev();
        updatePage(currentPage);
    }
    public void first(){
        currentPage = 0;
        hNext = hasNext();
        hPrev = hasPrev();
        updatePage(currentPage);
    }
    public void next(){
        hNext = hasNext();
        if(hNext == true){
            currentPage++;
            updatePage(currentPage);
        }
        hNext = hasNext();
        hPrev = hasPrev();
    }
    public void previous(){
        hPrev = hasPrev();
        if(hPrev == true){
            currentPage--;
            updatePage(currentPage);
        }
        
        
    }
    public boolean hasNext(){
        return (currentPage < lastPage);
    }
    public boolean hasPrev(){
        return (currentPage > 0);
    }
    
    Public List<SelectOption> pageNumbers{get;set;}
    Public String pageSelected {get;set;}
    public void getPageOptions(){
        pageNumbers = new List<SelectOption>();
        for(integer i = 1; i < lastPage + 2; i++){
            pageNumbers.add(new SelectOption(String.valueOf(i-1), String.valueOf( i)));
        }
        pageSelected = '0';
    }
    public void pageSelect(){
        currentPage = Integer.valueOf(pageSelected);
        updatePage(currentPage);
        hNext = hasNext();
        hPrev = hasPrev();
    }
    /*
    public PageReference distributeViaEmail(){
        if (emailIdArray.length() > 0){
            
        }
        else{
            ApexPages.CurrentPage.addMessage(
                new Message()
            );
        }
    }

    public PageReference downloadToLocal(){

    }
    */
}