public with sharing class AddProductWizardController 
{
    public Opportunity opp{get;set;}
    public List<SelectLineItem> lineItems {get;set;}
    public List<SelectLineItem> clonedLineItems {get;set;}
    public List<SelectPackage> packages {get;set;}
    public String currentSection {get;set;}
    public String message{get;set;}
    public String selectedShow {get;set;}
    public String selectedFamily {get;set;}
    public List<SelectPackage> selectedPackages {get;set;}
    public List<SelectLineItem> selectedProducts {get;set;}
    public final String OPTIONS_STEP = 'Options';
    public final String ADD_PACKAGE_STEP = 'Add Package';
    public final String ADD_PRODUCTS_STEP = 'Add Products';
    public final String EDIT_INFO_STEP = 'Edit Info';
    public Integer cartItemId {get;set;}
    public Integer selectedItemId {get;set;}
    List<SelectOption> options{get;set;} //show/publication options
    public ID selectedPricebookEntryId{get;set;}
    public Integer selectedItemNumber {get;set;}
    public Map<Id, Show_Publications__c> showPubMap = new Map<Id, Show_Publications__c>();
    
    public AddProductWizardController()
    {
        String oppId = ApexPages.currentPage().getParameters().get('id');
        List<Opportunity> opps = (oppId != null && oppId != '') ? [SELECT Id, Name FROM Opportunity WHERE Id =: oppId] : null;
        
        if(opps == null || opps.isEmpty())
        {
            this.message = 'Invalid opportunity ID.';
        }
        else
        {
            this.opp = opps[0];
            selectedPackages = new List<SelectPackage>();
            selectedProducts = new List<SelectLineItem>();
            
            this.currentSection = OPTIONS_STEP;
            this.cartItemId = 1;
        }
    }
    
    public void clearMessage()
    {
        this.message = null;
    }
            
    public void backClick()
    {
        clearMessage();
        this.packages = null;
        this.lineItems = null;
        this.selectedShow = null;
        this.selectedFamily = null;
        
        this.currentSection = OPTIONS_STEP;
    }
    
    public void editInfoBackClick()
    {
        clearMessage();     
        this.currentSection = ADD_PRODUCTS_STEP;
    }
    
    public void addPackagesClick()
    {
        clearMessage();
        this.currentSection = ADD_PACKAGE_STEP;
    }
    
    public void addProductsClick()
    {
        clearMessage();
        this.currentSection = ADD_PRODUCTS_STEP;
    }
    
    public void saveAndAddPackagesClick()
    {
        clearMessage();
        if(addPackagesToCart())
        {
            this.currentSection = ADD_PACKAGE_STEP;
        }
    }
    
    public void savePackagesClick()
    {
        clearMessage();
        if(addPackagesToCart())
        {
            this.currentSection = OPTIONS_STEP;
        }
    }
    
    public boolean addPackagesToCart()
    {
        boolean hasItems = false;
        
        if(this.packages != null && !this.packages.isEmpty())
        {
            for(SelectPackage sp : this.packages)
            {
                if(sp.selected)
                {
                    SelectPackage p = new SelectPackage();
                    p.itemNumber = this.cartItemId;
                
                    for(SelectLineItem sli : sp.lineItems)
                    {
                        p.lineItems.add(cloneSelectedItem(sli));
                    }
                    
                    p.selected = sp.selected;
                    p.quantity = sp.quantity;
                    p.sponsorPackage = sp.sponsorPackage.clone(true, true, false, false);
                    
                    this.selectedPackages.add(p);
                    
                    hasItems = true;
                    this.cartItemId++;
                    sp.selected = false;
                }
            }
        }        
        
        if(!hasItems)
        {
            this.message = 'You must select at least one package.';
        }
        else
        {
            //Clear package list no need to keep them in view state
            this.packages = null;
            this.selectedShow = null;
        }
        
        return hasItems;
    }
    
    public void continueClick()
    {
        Boolean hasItems = false;
        Boolean hasShows = true; 
        clearMessage(); 
        
        if(this.lineItems != null && !this.lineItems.isEmpty())
        {
            for(SelectLineItem item : this.lineItems)
            {
                if(item.selected)
                {   
                    hasItems = true;
                    
                    if(item.oli.Show_Event_Publication__c == null)
                    {
                    	hasShows = false;
                    	break;
                    }
                }
            }
        }
        
        if(hasItems)
        {
        	if(!hasShows)
        	{
        		this.message = 'You must select a Show/Publication for each selected product.';
        	}
        	else
        	{
            	this.currentSection = EDIT_INFO_STEP;     
        	}  
        }
        else
        {
            this.message = 'You must select at least one product.';
        }
    }
  
    private SelectLineItem cloneSelectedItem(SelectLineItem item)
    {
        SelectLineItem sli = new SelectLineItem();
        
        sli.itemNumber = this.cartItemId;
        sli.fieldSet = item.fieldSet;
        sli.oli = item.oli.clone(false, true, false, false);
        sli.selected = item.selected;
        
        return sli;
    }
    
    public List<SelectLineItem> getCurrentlySelectedProducts()
    {
        List<SelectLineItem> selected = new List<SelectLineItem>();
        showPubMap = getSelectedShowsPublications();
        Show_Publications__c selectedShowPub;
        this.selectedItemId = 1; 
        
        if(this.lineItems != null && !this.lineItems.isEmpty())
        {
            for(SelectLineItem item : this.lineItems)
            {
                if(item.selected)
                {
                    if(item.oli.Insertion_Date__c == null)
                    {
                    	selectedShowPub = showPubMap.get(item.oli.Show_Event_Publication__c);
                    	item.oli.Insertion_Date__c = selectedShowPub.Show_Start_Date__c;
                    }
                    item.itemNumber = this.selectedItemId;
                    selected.add(item);
                    this.selectedItemId++;
              }
            }
        }
        
        if(this.clonedLineItems != null && !this.clonedLineItems.isEmpty())
        {
            for(SelectLineItem item : this.clonedLineItems)
            {
                if(item.oli.Insertion_Date__c == null)
                {
                	selectedShowPub = showPubMap.get(item.oli.Show_Event_Publication__c);
                	item.oli.Insertion_Date__c = selectedShowPub.Show_Start_Date__c;
                }
                item.itemNumber = this.selectedItemId;
                selected.add(item);
                this.selectedItemId++;
            }
        }
        
        return sortItems(selected);
        //return selected;
    }   
    
    public Map<Id, Show_Publications__c> getSelectedShowsPublications() 
    {
    	if(this.lineItems != null && !this.lineItems.isEmpty())
        {
            for(SelectLineItem item : this.lineItems)
            {
            	if(item.selected)
                {
                    showPubMap.put(item.oli.Show_Event_Publication__c,
                    	[Select Id, Name, Show_Start_Date__c From Show_Publications__c Where Id = :item.oli.Show_Event_Publication__c]);
                }
            }
        }
        if(this.clonedLineItems != null && !this.clonedLineItems.isEmpty())
        {
            for(SelectLineItem item : this.clonedLineItems)
            {
                showPubMap.put(item.oli.Show_Event_Publication__c,
                	[Select Id, Name, Show_Start_Date__c From Show_Publications__c Where Id = :item.oli.Show_Event_Publication__c]);
            }
        }
        return showPubMap;
    }
    
    public void saveAndAddProductsClick()
    {
        clearMessage();
        if (addSelectedProductsToCart())
        {
            this.currentSection = ADD_PRODUCTS_STEP;
        }
    }
    
    public void saveProductsClick()
    {
        clearMessage();

        if(addSelectedProductsToCart())
        {
            this.currentSection = OPTIONS_STEP;
        }
    }
    
    public boolean addSelectedProductsToCart()
    {
        boolean success = true;
        if (this.lineItems != null)
        {
            for(SelectLineItem item : this.lineItems){
                if (item.selected && item.oli.Discount != 0 && item.oli.Discount != null && String.isBlank(item.oli.Discount_Code__c)){
                    success = false;
                    this.message = 'A discount code is required when assigning a discount.';
                }
            }
        }

        if(success && this.lineItems != null && !this.lineItems.isEmpty())
        {
            for(SelectLineItem item : this.lineItems)
            {
                if(item.selected)
                {   
                	//System.debug('add line item: ' + this.cartItemId);
                    this.selectedProducts.add(cloneSelectedItem(item));
                    
                    item.selected = false;
                    this.cartItemId++;
                }
            }
            
            if(this.clonedLineItems != null && !this.clonedLineItems.isEmpty())
        	{
            	for(SelectLineItem item : this.clonedLineItems)
            	{
                	//System.debug('add line item: ' + this.cartItemId);
                	this.selectedProducts.add(cloneSelectedItem(item));                    
                 	this.cartItemId++;              
            	}
        	}
        	
        	selectedProducts = sortItems(selectedProducts);
            
            //Clear product list no need to keep them in view state
            this.lineItems = null;
            this.selectedFamily = null;
            this.clonedLineItems = null;
        }
        return success;
    }
    
    public void cloneProductClick()
    {
        clearMessage();
        // add clone of selected product to currentlySelectedProducts
        if(this.clonedLineItems == null)
        {
        	this.clonedLineItems = new List<SelectLineItem>();
        }
        
        for(SelectLineItem item : getCurrentlySelectedProducts())
        {
        	//system.debug('CloneProd: For - item pbe: ' + item.oli.PricebookEntry.Id + ' ; sel pbe: ' + this.selectedPricebookEntryId);
        	//system.debug('CloneProd: For - item number: ' + item.itemNumber + ' ; sel itemNumber: ' + this.selectedItemNumber);
            if(item.oli.PricebookEntry.Id == this.selectedPricebookEntryId && (item.itemNumber == null  || item.itemNumber == this.selectedItemNumber))
            {
                this.clonedLineItems.add(cloneSelectedItem(item));
                break;
            }
        } 
    }
    
    public void updateShowPub()
    {
        Show_Publications__c selectedShowPub;
        clearMessage();
        
        for(SelectLineItem item : getCurrentlySelectedProducts())
        {
        	//system.debug('Update Show/Pub: For - item pbe: ' + item.oli.PricebookEntry.Id + ' ; sel pbe: ' + this.selectedPricebookEntryId);
        	//system.debug('Update Show/Pub: For - Item Number: ' + item.itemNumber + ' ; sel itemNumber: ' + this.selectedItemNumber);
        	
            if(item.oli.PricebookEntry.Id == this.selectedPricebookEntryId && (item.itemNumber == null || item.itemNumber == this.selectedItemNumber))
            {   
                selectedShowPub = this.showPubMap.get(item.oli.Show_Event_Publication__c);
               	item.oli.Insertion_Date__c = selectedShowPub.Show_Start_Date__c;
                break;
            }
        } 
    }
    
    public void removeProductClick()
    {
        clearMessage();
        // remove selected product from selectedProducts list      
        Integer index = 0;  
        Integer rowToRemove;
        for(SelectLineItem item : this.selectedProducts)
        {
            if(item.oli.PricebookEntry.Id == this.selectedPricebookEntryId && (item.itemNumber == null || item.itemNumber == this.selectedItemNumber))
            {   
                rowToRemove = index;
                break;
            }
            index++;
        } 
        
        if(rowToRemove != null)
        {
        	this.selectedProducts.remove(rowToRemove);
        	
        }
    }
    
    public PageReference submitClick()
    {
        PageReference ref = null;
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        Savepoint savePnt = null;
                        
        try
        {
            clearMessage();
            
            savePnt = Database.setSavepoint();
            
            if(!this.selectedProducts.isEmpty())
            {
                for(SelectLineItem sli : this.selectedProducts)
                {                    
                    if(sli.oli.OpportunityId == null)
                    {
                        sli.oli.OpportunityId = this.opp.Id;                        
                    }
                    
                    olis.add(sli.oli);                    
                }   
            }
              
            if(!this.selectedPackages.isEmpty())
            {
                for(SelectPackage sp : this.selectedPackages)
                {
                	//Need opp package id for line item... saving opp packages one at a time
                	List<Opportunity_Package__c> oppPackages = new List<Opportunity_Package__c>();
                    
                    oppPackages.add(new Opportunity_Package__c(Opportunity__c = this.opp.Id, Sponsorship_Package__c = sp.SponsorPackage.Id, Quantity__c = sp.quantity));
                    
                    SharingOverride.UpsertRecords(oppPackages);
                    
                    for(SelectLineItem sli : sp.lineItems)
                    {
                        if(sli.oli.OpportunityId == null)
                        {
                            sli.oli.OpportunityId = this.opp.Id;
                        }
                        
                        sli.oli.Sponsorship_Package__c = sp.SponsorPackage.Id;
                        sli.oli.Opportunity_Package__c = oppPackages[0].Id;
                        sli.oli.Quantity = sli.oli.Quantity * sp.quantity;
                        olis.add(sli.oli);
                    }                    
                }           
            }
                        
            
            if(!olis.isEmpty())
            {
                SharingOverride.UpsertRecords(olis);
            }
            
            ref = new PageReference('/' + this.opp.Id);
            ref.setRedirect(true);
            
            return ref;
        }
        catch(Exception ex)
        {
            //Rollback on error
            if(savePnt != null)
            {
                Database.rollback(savePnt);
            }
            this.message = ex.getMessage() + ex.getStackTraceString();
        }
            
        return null;
        
    }
        
    public List<SelectOption> getShows()
    {
        if(this.options == null)
        {
            this.options = new List<SelectOption>();
            List<Show_Publications__c> sps = [SELECT Id, Name FROM Show_Publications__c WHERE Show_Start_Date__c >= :Date.today() OR Show_End_Date__c >= :Date.today() OR Reopen_Show__c = true Order By Name];
            
            this.options.add(new SelectOption('',''));
            for(Show_Publications__c sp : sps)
            {
                this.options.add(new SelectOption(sp.id, sp.Name));
            }
        }

        return this.options;
    }
    
    public SelectOption getMembershipOption()
    {
    	 List<SelectOption> shows = getShows();
    	 SelectOption opt = null;
    	 
    	 for(SelectOption o : shows)
    	 {
    	 	if(o.getLabel().toLowerCase().indexOf('membership') >= 0)
    	 	{
    	 		opt = o;
    	 		break;
    	 	}
    	 }
    	 
    	 return opt;
    }
    
    public List<SelectOption> getFamilies()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('',''));
	        
		for( Schema.PicklistEntry f : ple)
		{
			options.add(new SelectOption(f.getLabel(), f.getValue()));
		}      
	        
        return sortOptions(options);
    }
    
    public void onShowChange()
    {
        this.packages = null;
        this.lineItems = null;
    }
    
    public List<SelectPackage> getPackageList()
    {
        List<PricebookEntry> pricebooks = new List<PricebookEntry>();
        Map<String, List<Schema.FieldSetMember>> productFamilyFieldSets = new Map<String, List<Schema.FieldSetMember>>();
        //Map<Id, Sponsorship_Package__c> packageMap = null;
        Map<Id, PricebookEntry> productIdToPricebookMap = new Map<Id, PricebookEntry>();
        List<Sponsorship_Package__c> sps = null;
        Set<ID> packageIds = new Set<Id>();
        String query = null;
                
        if(this.packages == null)
        {
            this.packages = new List<SelectPackage>();
            
            /*packageMap = new Map<Id, Sponsorship_Package__c>([SELECT Id, Name, Total_Price_of_Line_Items__c, Maximum_Units__c, Units_Pending__c, Units_Sold__c, Show_Publication__c,  
                                                                (SELECT Product__c, Sales_Price__c, Color__c, Insertion_Date__c, Position__c, Quantity__c   FROM Package_Line_Items__r) 
                                                                FROM Sponsorship_Package__c 
                                                                WHERE Show_Publication__c =: this.selectedShow Order By Name]);
            */
            sps = [SELECT Id, Name, Total_Price_of_Line_Items__c, Maximum_Units__c, Units_Pending__c, Units_Sold__c, Show_Publication__c,  
                                                                (SELECT Product__c, Sales_Price__c, Color__c, Insertion_Date__c, Position__c, Quantity__c, Line_Description__c, Show_Publication__c, Show_Publication__r.Name  FROM Package_Line_Items__r)
                                                                FROM Sponsorship_Package__c 
                                                                WHERE Show_Publication__c =: this.selectedShow Order By Name];
                                                                
            for(Sponsorship_Package__c sp : sps)
            {
                packageIds.add(sp.Id);
            }

            pricebooks = [SELECT Id, Product2.Id, Product2.Name, UnitPrice, Product2.Family 
                            FROM PricebookEntry 
                            WHERE IsActive = true AND Pricebook2.IsStandard = true AND Pricebook2.IsActive = true
                                AND Product2Id in (SELECT Product__c FROM Package_Line_Item__c WHERE Sponsorship_Package__c in:packageIds)];
                                
            for(PricebookEntry pbe : pricebooks)
            {
                productIdToPricebookMap.put(pbe.Product2.Id, pbe);
            }
        
           // sps = packageMap.values();
            for(Sponsorship_Package__c sp : sps)
            {
                SelectPackage p = new SelectPackage();
                
                if(sp.Maximum_Units__c  == null)
                {
                    sp.Maximum_Units__c = 0;
                }
                
                if(sp.Units_Pending__c  == null)
                {
                    sp.Units_Pending__c = 0;
                }
                
                if(sp.Units_Sold__c  == null)
                {
                    sp.Units_Sold__c = 0;
                }
                
                p.sponsorPackage = sp;
                
                for(Package_Line_Item__c pli : sp.Package_Line_Items__r)
                {
                    PricebookEntry pbe = productIdToPricebookMap.get(pli.Product__c);
                    
                    if(pbe != null)
                    {
                        SelectLineItem item = new SelectLineItem();
                        
                        /*if(pbe.Product2.Family != null && pbe.Product2.Family != '')
                        {
                            item.fieldSet = getProductFamilyFields(pbe.Product2.Family);
                        }
                        */
                        
                        item.oli.UnitPrice = pli.Sales_Price__c;
                        item.oli.Quantity =  pli.Quantity__c;
                        item.oli.PricebookEntryId = pbe.Id;
                        item.oli.Sponsorship_Package__c = sp.Id;
                        item.oli.PricebookEntry = pbe;
                        item.oli.Position__c = pli.Position__c;
                        item.oli.Insertion_Date__c = pli.Insertion_Date__c;
                        item.oli.Color__c = pli.Color__c;
                        item.oli.Description = pli.Line_Description__c;
                        item.oli.Show_Event_Publication__c = pli.Show_Publication__c;
                        item.productName = pbe.Product2.Name;
                        if (pli.Show_Publication__c != sp.Show_Publication__c){
                            item.productName += ' (' + pli.Show_Publication__r.Name + ')';
                        }

                        p.lineItems.add(item);
                    }
                }
                
                p.lineItems = sortItems(p.lineItems);
                
                this.packages.add(p);
            }
        }
        
        return this.packages;
    }   
    
    public List<Schema.FieldSetMember> getProductFamilyFields(string productFamily)
    {
        return getFieldSetMembers('OpportunityLineItem', productFamily);
    }
    
    public static List<Schema.FieldSetMember> getFieldSetMembers(string objectName, string fieldSet)
    {
        Schema.DescribeSobjectResult[] objectResults = Schema.describeSObjects(new String[]{objectName});
        Schema.FieldSet fs = null;
        List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
        
        if(objectResults != null && objectResults.size() > 0)
        {
            fs = objectResults[0].fieldSets.getMap().get(fieldSet.toLowerCase());
            
            if(fs != null)
            {
                fieldSetMembers = fs.getFields();
            }
        }       
        
        return fieldSetMembers;
    }
    
    public List<SelectLineItem> getProducts()
    {
        List<PricebookEntry> pricebooks = new List<PricebookEntry>();
        Map<String, List<Schema.FieldSetMember>> productFamilyFieldSets = new Map<String, List<Schema.FieldSetMember>>();
        SelectOption membershipShowOption = null;
        
        if(this.lineItems == null)
        {
        	if(this.selectedFamily != null && this.selectedFamily.toLowerCase() == 'membership')
        	{
        		membershipShowOption = getMembershipOption();
        	}
        	
            this.lineItems = new List<SelectLineItem>();
            pricebooks = [SELECT Id, Product2.Id, Product2.Name, UnitPrice, Product2.Family, Product2.Description 
                            FROM PricebookEntry 
                            WHERE IsActive = true AND Pricebook2.IsStandard = true AND Pricebook2.IsActive = true 
                            AND Product2.Family =: this.selectedFamily AND Product2.For_Packages_Only__c = false
                            Order By Product2.Name];
        
            for(PricebookEntry pbe : pricebooks)
            {
                SelectLineItem item = new SelectLineItem();
                
                if(pbe.Product2.Family != null && pbe.Product2.Family != '')
                {
                    item.fieldSet = getProductFamilyFields(pbe.Product2.Family);
                }
                
                item.oli.UnitPrice = pbe.UnitPrice;
                item.oli.Quantity =  1;
                item.oli.PricebookEntryId = pbe.Id;                
                item.oli.PricebookEntry = pbe;
               // item.oli.Description = pbe.Product2.Description;
                
                if(membershipShowOption != null)
                {
                	item.oli.Show_Event_Publication__c = membershipShowOption.getValue();
                }
                
                this.lineItems.add(item);
            }
        }
        
        return this.lineItems;
    }  
    
    public List<SelectLineItem>  sortItems(List<SelectLineItem> items)
    {
        List<SelectLineItem> returnList = null;
        List<SelectLineItem> less = null;
        List<SelectLineItem> greater = null;
        SelectLineItem pivotValue = null;
        Integer pivot = 0;
        String itemKey = null;
        String pivotKey = null;
        
        if(items == null || items.size() <= 1)
            return items;
        
        returnList = new List<SelectLineItem> ();
        less = new List<SelectLineItem>();
        greater = new List<SelectLineItem>();
        
        // save the pivot and remove it from the list
        pivotValue = items[pivot];
        pivotKey = pivotValue.oli.PricebookEntry.Product2.Name + pivotValue.oli.Insertion_date__c; 
        items.remove(pivot);
        
        for(SelectLineItem x : items)
        {
            itemKey = x.oli.PricebookEntry.Product2.Name + x.oli.Insertion_date__c;
            if(itemKey <= pivotKey)
            {
                less.add(x);
            }
            else if(itemKey > pivotKey)
            {
                greater.add(x);    
            }
        }
        
        returnList.addAll(sortItems(less));
        returnList.add(pivotValue);
        returnList.addAll(sortItems(greater));
        
        return returnList; 
    } 
    
    public List<SelectOption>  sortOptions(List<SelectOption> items)
    {
        List<SelectOption> returnList = null;
        List<SelectOption> less = null;
        List<SelectOption> greater = null;
        SelectOption pivotValue = null;
        Integer pivot = 0;
        
        if(items == null || items.size() <= 1)
            return items;
        
        returnList = new List<SelectOption> ();
        less = new List<SelectOption>();
        greater = new List<SelectOption>();
        
        // save the pivot and remove it from the list
        pivotValue = items[pivot];
        items.remove(pivot);
        
        for(SelectOption x : items)
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
        
        returnList.addAll(sortOptions(less));
        returnList.add(pivotValue);
        returnList.addAll(sortOptions(greater));
        
        return returnList; 
    } 
    
    public class SelectPackage
    {
        public Sponsorship_Package__c sponsorPackage{get;set;}
        public List<SelectLineItem> lineItems{get;set;} 
        public Boolean selected {get;set;}  
        public Integer itemNumber{get;set;}
        public Decimal quantity{get;set;}
        
        public SelectPackage()
        {
            lineItems = new List<SelectLineItem>();
            selected = false;
            quantity = 1;
        }
    }
    
    public class SelectLineItem
    {
        public OpportunityLineItem oli{get;set;}
        public Boolean selected {get;set;}  
        public List<Schema.FieldSetMember> fieldSet{get;set;} 
        public Integer itemNumber{get;set;}
        public String productName{get;set;}
        
        public SelectLineItem()
        {   
            oli = new OpportunityLineItem();
            fieldSet = new List<Schema.FieldSetMember>();
            selected = false;
            productName = '';
        }  
    } 
}