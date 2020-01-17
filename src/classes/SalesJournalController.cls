public with sharing class SalesJournalController {
	public boolean allSelected{get{
		if (allSelected == null) allSelected = false;
		return allSelected;
	}set;}
    public boolean hNext{get;set;}
    public boolean hPrev{get;set;}
    private static Integer PAGE_SIZE = 50;
    private Integer lastPage;
    private Integer currentPage;
	public Id showId{get;set;}
	public Show_Publications__c show{get{
		if (show == null && showId != null){
			show = [Select Id, Name from Show_Publications__c where Id = :showId];
		}
		return show;
	}set;}
	public List<RowModel> rows{get;set;}
    private Map<Integer, Set<Id>> pages;
    private List<OrderItem> displayOrderItems;
	public List<OrderItem> orderItems{get{
		if (orderItems == null && String.isNotBlank(showId)){
			orderItems = [Select Id /*, 
				OrderItemNumber,
				PricebookEntry.Product2.Page_Count__c,
				Show_Event_Publication__r.Show_Start_Date__c,
				Order.Ad_Agency__r.Name,
				Order.Account.Name,
				Order.Account_to_Bill__c,
				Size__c,          
				UnitPrice,
				Color__c,
				Position__c,
                Discount__c, 
                Adjusted_Price__c,
                Total_Price_Formula__c */
				from OrderItem
				where Show_Event_Publication__c = :showId
                         order by OrderItemNumber];
		}
		return orderItems;
	}set;}
	public Map<Id,Invoice__c> invoiceMap{get{
		if (invoiceMap == null && String.isNotBlank(showId)){
			List<Invoice__c> invoices = [Select Id,
					Invoice_Date__c,
					Name,
					Product__c,
					Product__r.Show_Event_Publication__r.Show_Start_Date__c,
					Product__r.Order.Ad_Agency__r.Name,
					Product__r.Order.Account_to_Bill__c,
					Product__r.Size__c,
					Product__r.ListPrice,
					Product__r.Color__c,
					Authorized_For_Printing__c
				from Invoice__c 
				where Product__c in :orderItems];
				invoiceMap = new Map<Id,Invoice__c>();
				for (Invoice__c inv : invoices){
					invoiceMap.put(inv.Product__c, inv);
				}
		}
		return invoiceMap;
	}set;}

	public SalesJournalController(){
        pages = new Map<Integer, Set<Id>>();
        rows = new List<RowModel>();
		showId = ApexPages.currentPage().getParameters().get('id');
		if (String.isBlank(showId)) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No show/publication selected.'));
		else if (rows.size() == 0) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No invoices found for selected show/publication.'));
        currentPage = 0;
        boolean done = false;
        
        Integer i = 0;
        if(!orderItems.isEmpty()){
            while(!done){
                Set<Id> page = new Set<Id>();
                for(Integer j= i* PAGE_SIZE; j<(i*PAGE_SIZE + PAGE_SIZE) && j<orderItems.size(); j++){
                    page.add(orderItems.get(j).id);
                    if(j == orderItems.size() - 1)
                        done = true;
                }
                pages.put(i, page);
                if(done)
                    break;
                else
                    i++;
            }
            lastPage = i;
            hNext = hasNext();
            hPrev = hasPrev();
            getPageOptions();
            updateRows(currentPage);
        }
        
	}
    public void first(){
        currentPage = 0;
        updateRows(currentPage);
        hNext = hasNext();
        hPrev = hasPrev();
    }
    public void last(){
        currentPage = lastPage;
        updateRows(currentPage);
        hNext = hasNext();
        hPrev = hasPrev();
    }
    public void next(){
        if(hNext){
            currentPage++;
            updateRows(currentPage);
        }
        hNext = hasNext();
        hPrev = hasPrev();
        
    }
    public void previous(){
        if(hPrev){
            currentPage--;
            updateRows(currentPage);
        }
        hNext = hasNext();
        hPrev = hasPrev();
    }
    private boolean hasNext(){
        return (currentPage < lastPage);
    }
    private boolean hasPrev(){
        return (currentPage > 0);
    }
    private void updateRows(Integer newPage){
        if(rows == null)
            rows = new List<RowModel>();
        rows.clear();
        displayOrderItems = [Select Id, 
				OrderItemNumber,
				PricebookEntry.Product2.Page_Count__c,
				Show_Event_Publication__r.Show_Start_Date__c,
				Order.Ad_Agency__r.Name,
				Order.Account.Name,
				Order.Account_to_Bill__c,
				Size__c,          
				UnitPrice,
				Color__c,
				Position__c,
                Discount__c, 
                Adjusted_Price__c,
                Total_Price_Formula__c 
				from OrderItem
				where Show_Event_Publication__c = :showId and id in : pages.get(newPage)
                            order by OrderItemNumber];
        for (OrderItem item : displayOrderItems){
                rows.add(new RowModel(item,invoiceMap.get(item.Id)));
            }
        if (rows.size() > 0 && currentPage == lastPage){
            rows.add(
                getTotalsRow(showId)
            );
        }
        pageSelected = String.valueOf(currentPage);
    }

	public void generateInvoices(){
		List<Invoice__c> toInsert = new List<Invoice__c>();
        List<OrderItem> oItems = [Select Id, 
				OrderItemNumber,
				PricebookEntry.Product2.Page_Count__c,
				Show_Event_Publication__r.Show_Start_Date__c,
				Order.Ad_Agency__r.Name,
				Order.Account.Name,
				Order.Account_to_Bill__c,
				Size__c,          
				UnitPrice,
				Color__c,
				Position__c,
                Discount__c, 
                Adjusted_Price__c,
                Total_Price_Formula__c 
				from OrderItem
				where Show_Event_Publication__c = :showId
                order by OrderItemNumber];
        List<RowModel> genRows = new List<RowModel>();
        for(OrderItem item : oItems){
            genRows.add(new RowModel(item,invoiceMap.get(item.Id)));
            
        }
        System.debug('GenRows: ' +genRows);
		for (RowModel row : genRows){
			if (row.invId == null && row.orderItem != null) toInsert.add(generateInvoice(row.orderItem));
		}/*
		orderItems = null; //reinitialize the page 
		invoiceMap = null;
		rows = null; */
        insert toInsert;

        orderItems = [Select Id
                      from OrderItem
                      where Show_Event_Publication__c = :showId
                      order by OrderItemNumber];
        List<Invoice__c> invoices = [Select Id,
					Invoice_Date__c,
					Name,
					Product__c,
					Product__r.Show_Event_Publication__r.Show_Start_Date__c,
					Product__r.Order.Ad_Agency__r.Name,
					Product__r.Order.Account_to_Bill__c,
					Product__r.Size__c,
					Product__r.ListPrice,
					Product__r.Color__c,
					Authorized_For_Printing__c
				from Invoice__c 
				where Product__c in :orderItems];
        invoiceMap = new Map<Id,Invoice__c>();
        for (Invoice__c inv : invoices){
            invoiceMap.put(inv.Product__c, inv);
        }
        updateRows(currentPage);
	}

	public Invoice__c generateInvoice(OrderItem oi){
		Invoice__c invoice = new Invoice__c();
		invoice.Product__c = oi.Id;
		invoice.Invoice_Date__c = Date.today();
		invoice.Status__c = 'DRAFT';
		return invoice;
	}

	public void authorizeInvoices(){
		List<Invoice__c> toUpdate = new List<Invoice__c>();
		for (RowModel r : rows){
			if (r.invoice != null && r.selected){ 
				r.invoice.Authorized_For_Printing__c = true;
				toUpdate.add(r.invoice);
				//r.selected = false;
			}
		}
		update toUpdate;
		orderItems = [Select Id
                      from OrderItem
                      where Show_Event_Publication__c = :showId
                      order by OrderItemNumber];
        List<Invoice__c> invoices = [Select Id,
					Invoice_Date__c,
					Name,
					Product__c,
					Product__r.Show_Event_Publication__r.Show_Start_Date__c,
					Product__r.Order.Ad_Agency__r.Name,
					Product__r.Order.Account_to_Bill__c,
					Product__r.Size__c,
					Product__r.ListPrice,
					Product__r.Color__c,
					Authorized_For_Printing__c
				from Invoice__c 
				where Product__c in :orderItems];
        invoiceMap = new Map<Id,Invoice__c>();
        for (Invoice__c inv : invoices){
            invoiceMap.put(inv.Product__c, inv);
        }
        updateRows(currentPage);
	}


	public void changeSelectAll(){
		if (allSelected) selectAll();
		else unselectAll();
	}

	public void selectAll(){
		for (RowModel row : rows){
			row.selected = true;
		}
	}

	public void unselectAll(){
		for (RowModel row : rows){
			row.selected = false;
		}
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
        updateRows(currentPage);
        hNext = hasNext();
        hPrev = hasPrev();
    }
	class RowModel{
		OrderItem orderItem{get;set;}
		Invoice__c invoice{get;set;}
		public Id accountId{get;set;}
		public Id orderItemId{get;set;}
		public String orderItemNumber{get;set;}
		public Id invId{get;set;}
		public String invDate{get;set;}
		public String invNumber{get;set;}
		public String coverDate{get;set;}
		public String advertiser{get;set;}
		public boolean bill{get;set;}
		public String agency{get;set;}
		public decimal pages{get;set;}
		public String adSize{get;set;}
		public decimal spaceChg{get;set;}
		public String color{get;set;}
		public decimal colorChg{get;set;}
		public boolean bleed{get;set;}//return orderItem.Bleed__c;}}
		public decimal bleedChg{get;set;}
		public String position{get;set;}
		public decimal positionChg{get;set;}
		public decimal mediaTotal{get;set;}
		public decimal prodChg{get;set;}
		public decimal orderTtl{get;set;}
		public decimal discTotal{get;set;}
		public decimal taxCost{get;set;}
		public decimal netTotal{get;set;}
		public boolean authorized{get;set;}
		public boolean selected{get;set;}
        public boolean isTotalRow{get;set;}

		public RowModel(OrderItem o, Invoice__c i){
            isTotalRow = false;
			orderItem = o;
			invoice = i;
			accountId = orderItem.Order.AccountId;
			orderItemId = orderItem.Id;
			orderItemNumber = orderItem.OrderItemNumber;
			invId = (invoice == null)? null : invoice.Id;
			invDate = (invoice == null || invoice.Invoice_Date__c == null)? null : dateToFormattedString(invoice.Invoice_Date__c);
			invNumber = (invoice == null)? 'n/a' : invoice.Name;
			coverDate = (orderItem.Show_Event_Publication__r.Show_Start_Date__c == null)? null : dateToFormattedString(orderItem.Show_Event_Publication__r.Show_Start_Date__c);
			advertiser = orderItem.order.Account.Name;
			bill = (orderItem.Order.Account_to_Bill__c == 'Ad Agency');
			agency = (orderItem.Order.Ad_Agency__c == null)? null : orderItem.Order.Ad_Agency__r.Name;
			pages = orderItem.PricebookEntry.Product2.Page_Count__c;
			adSize = orderItem.Size__c;
			spaceChg = orderItem.Total_Price_Formula__c;
			color = orderItem.Color__c;
			colorChg = null;
			bleed = null;
			bleedChg = null;
			position =  orderItem.Position__c;
			positionChg = null;
			mediaTotal = (orderItem.Total_Price_Formula__c == null) ? null:  orderItem.Total_Price_Formula__c;
			prodChg = null;
			orderTtl = null;
			discTotal = (orderItem.Discount__c == null)? null: orderItem.Discount__c;
			taxCost = null;
            netTotal = (orderItem.Adjusted_Price__c == null) ? null: orderItem.Adjusted_Price__c;
			authorized = (invoice==null)? null : invoice.Authorized_For_Printing__c;
			selected = false;
		}

		public RowModel(){} // for totals row, manually set values
	}

	public static RowModel getTotalsRow(Id showId){
		RowModel totals = new RowModel();
        totals.isTotalRow = true;
		totals.pages = 0;
		totals.spaceChg = 0;
		totals.colorChg = 0;
		totals.bleedChg = 0;
		totals.positionChg = 0;
		totals.mediaTotal = 0;
		totals.prodChg = 0;
		totals.orderTtl = 0;
		totals.discTotal = 0;
		totals.taxCost = 0;
		totals.netTotal = 0;
        
        List<AggregateResult> aggrResults = [Select sum(ListPrice) LiPrice, sum(PricebookEntry.Product2.Page_Count__c) PCount, sum(Total_Price_Formula__c) spaceMedChg,
                                            sum(Discount__c) Disc, sum(Adjusted_Price__c) AdjPrice from OrderItem where Show_Event_Publication__c = :showId];
        AggregateResult aggrResult = aggrResults[0];
        totals.pages = (Decimal) aggrResult.get('PCount');
        totals.spaceChg = (Decimal) aggrResult.get('spaceMedChg');
        totals.mediaTotal = (Decimal) aggrResult.get('spaceMedChg');
        totals.discTotal = (Decimal) aggrResult.get('Disc');
        totals.netTotal = (Decimal) aggrResult.get('AdjPrice');
		return totals;
	}

	public static String dateToFormattedString(Date d){
		String dateFormat = 'MMMMMMMMMMMMMMMM dd yyyy';
		if (d == null) return null;

		Datetime dt = datetime.newInstance(d.year(), d.month(), d.day());
		return dt.format(dateFormat);
	}
}