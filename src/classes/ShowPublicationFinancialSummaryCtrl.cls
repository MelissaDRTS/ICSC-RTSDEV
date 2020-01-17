public class ShowPublicationFinancialSummaryCtrl{
    public Id showPublicationId{get;set;}
    
    public Integer currentPage{get;set;}
    public boolean hNext{get{return hasNext();}set;}
    public boolean hPrev{get{return hasPrev();}set;}
    public Integer lastPage{get;set;}
    private static Integer PAGE_SIZE = 50;  
    public Map<Integer, Set<Id>> pages{get;set;}
    private transient List<OrderItem> displayOrderItems;
    public transient Show_Publications__c showPublication{get{
        if (showPublicationId == null) return null;
        else if (showPublication == null || showPublication.Id != showPublicationId){
            showPublication = [Select Name, Show_Start_Date__c from Show_Publications__c where Id = :showPublicationId limit 1];
        }
        return showPublication;
    }set;}
    public List<RowModel> rows{get;set;}/*{get{
        if (rows == null){
            rows = new List<RowModel>();
            for (OrderItem item : displayOrderItems){
                rows.add(new RowModel(item,itemInvoiceMap));
            }
            if (rows.size() > 0){
                rows.add(
                    getTotalRow(rows)
                );
            }
        }
        return rows;
    }set;}*/
    public transient List<OrderItem> orderItems{get{
        if (orderItems == null && showPublicationId != null){
            orderItems = [Select Id
                from OrderItem where Show_Event_Publication__c = :showPublicationId
                 and PricebookEntry.Product2.Family = 'Advertising'
                order by Order.Account.Name];
        }
        return orderItems;
    }set;}
    public Map<Id,Invoice__c> itemInvoiceMap{get{
        if (itemInvoiceMap == null){
            itemInvoiceMap = new Map<Id,Invoice__c>();
            List<Invoice__c> invoices = [Select Id, Name, Product__c from Invoice__c where Product__c in :OrderItems];
            System.debug('invoices.count = '+invoices.size());
            for (Invoice__c invoice : invoices){
                itemInvoiceMap.put(invoice.Product__c,invoice);
            }
        }
        return itemInvoiceMap;
    }set;}
    private List<Attachment> attachmentsList{get{
            if(attachmentsList == null){
                attachmentsList = [Select id, name, parentId from Attachment];
            }
            return attachmentsList;

        }set;}
    private Map<Id, Attachment> parent2attch {get{
            if(parent2attch == null){
                parent2attch = new Map<Id, Attachment>();
                for(Attachment a : attachmentsList){
                    parent2attch.put(a.parentId, a);
                }
            }
            return parent2attch;
        }set;}
    public String displayType{get;set;}
    public String printedDate{get{return Date.today().format();}}

    // sum row
    

    public ShowPublicationFinancialSummaryCtrl() {
        displayType = 'html';
        currentPage = 0;
        pages = new Map<Integer, Set<Id>>();
        rows = new List<RowModel>();
        showPublicationId = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(showPublicationId)) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No show/publication selected.'));
        //lastPage = Math.ceil(orderItems.size() / 100.0).intValue();
        
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
            updateRows(currentPage);
            getPageOptions();
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No order items found for this show/publication.'));
            
        }
    }
    public String notesToDisplay {get;set;}
    public boolean showModal {get{
    	if(showModal == null){
    		showModal=false;
    	}
    	return showModal;
    }set;}
    public void toggleModal(){
    	showModal = !showModal;
    }
    public void last(){
        currentPage = lastPage;
        hNext = hasNext();
        hPrev = hasPrev();
        updateRows(currentPage);
    }
    public void first(){
        currentPage = 0;
        hNext = hasNext();
        hPrev = hasPrev();
        updateRows(currentPage);
    }
    public void next(){
        hNext = hasNext();
        if(hNext == true){
            currentPage++;
            updateRows(currentPage);
        }
        hNext = hasNext();
        hPrev = hasPrev();
    }
    public void previous(){
        hPrev = hasPrev();
        if(hPrev == true){
            currentPage--;
            updateRows(currentPage);
        }
        
        
    }
    public boolean hasNext(){
        return (currentPage < lastPage);
    }
    public boolean hasPrev(){
        return (currentPage > 0);
    }
    private void updateRows(Integer newPage){
    	rows.clear();
        displayOrderItems = [Select Id,
                Order.ContractId,
                Accounting_Notes__c,
                OrderItemNumber,
                Order.AccountId,
                Order.Account.Name,
                Order.Account.iMIS_ID__c,
                Order.Ad_Agency__r.Name,
                Size__c,
                Color__c,
                Position__c,
                ListPrice,
                Total_Price_Formula__c,
                Adjusted_Price__c,
                Discount__c,
                Discount_Amount__c,
                PricebookEntry.Product2.Page_Count__c,
                OrderId,
                Order.TotalAmount,
                //Order.Agency_Discount__c,
                Order.Account_to_Bill__c,
                Order.BillToContact.Name,
                Order.OpportunityId,
                //Order.BillToContact.MailingAddress,
                Order.BillToContact.MailingStreet,
                Order.BillToContact.MailingCity,
                Order.BillToContact.MailingState,
                Order.BillToContact.MailingCountry,
                Order.BillToContact.MailingPostalCode,
                Order.Insertion_Order_Number__c,
                Order.OrderNumber,
                Order.Account.Owner.Name,
                Show_Event_Publication__r.Show_Start_Date__c,
                PricebookEntry.Product2.Name
                from OrderItem where Show_Event_Publication__c = :showPublicationId and Id in :pages.get(newPage)
                order by Order.Account.Name];
        
        for (OrderItem item : displayOrderItems){
                rows.add(new RowModel(item,itemInvoiceMap, parent2attch));
            }
            if (rows.size() > 0 && currentPage == lastPage){
                rows.add(
                    getTotalRow(showPublicationId)
                );
            }
        hPrev = hasPrev();
        hNext = hasNext();
        pageSelected = String.valueOf(currentPage);
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
    
    public PageReference goToPdf(){
        displayType = 'pdf';
        //PageReference pr = new PageReference('/apex/ShowPublicationFinancialSummary_table');
        displayOrderItems = [Select Id,
                Order.ContractId,
                OrderItemNumber,
                Order.AccountId,
                Order.Account.Name,
                Order.Account.IMIS_ID__c,
                Order.Ad_Agency__r.Name,
                Size__c,
                Color__c,
                Position__c,
                ListPrice,
                Total_Price_Formula__c,
                Adjusted_Price__c,
                Discount__c,
                Discount_Amount__c,
                PricebookEntry.Product2.Page_Count__c,
                OrderId,
                Accounting_Notes__c,
                Order.TotalAmount,
                //Order.Agency_Discount__c,
                Order.Account_to_Bill__c,
                Order.BillToContact.Name,
                Order.OpportunityId,
                //Order.BillToContact.MailingAddress,
                Order.BillToContact.MailingStreet,
                Order.BillToContact.MailingCity,
                Order.BillToContact.MailingState,
                Order.BillToContact.MailingCountry,
                Order.BillToContact.MailingPostalCode,
                Order.Insertion_Order_Number__c,
                Order.OrderNumber,
                Order.Account.Owner.Name,
                Show_Event_Publication__r.Show_Start_Date__c,
                PricebookEntry.Product2.Name
                from OrderItem where Show_Event_Publication__c = :showPublicationId
                order by Order.Account.Name];
        rows.clear();
        for (OrderItem item : displayOrderItems){
                rows.add(new RowModel(item,itemInvoiceMap, parent2attch));
                if(item.Accounting_Notes__c != null){
                	rows.add(getNotesRow(item.Accounting_Notes__c));
                }
            }
            if (rows.size() > 0){
                rows.add(
                    getTotalRow(showPublicationId)
                );
            }      
        PageReference pr = new PageReference('/apex/ShowPublicationFinancialSummary_PDF');
        pr.setRedirect(false);
        return pr;
    }
    public class RowModel{
		public boolean isTotalRow{get;set;}
        public String advertiser{get;set;}
        public String advId{get;set;}
        public String agency{get;set;}
        public String accountId{get;set;}
        public String size{get;set;}
        public decimal space{get;set;}
        public String color{get;set;}
        public decimal pages{get;set;}
        public decimal chg1{get;set;}
        public String position{get;set;}
        public decimal chg2{get;set;}
        public boolean bleed{get;set;}
        public decimal chg3{get;set;}
        public decimal totalMedia{get;set;}
        public decimal discount{get;set;}
        public decimal chg4{get;set;}
        public decimal netMedia{get;set;}
        public decimal chg5{get;set;}
        public decimal grossOrderTotal{get;set;}
        public String bill{get;set;}
        public decimal projectNet{get;set;}
        public Contact contact{get;set;}
        public String contactName{get{return contact.Name;}}
        public String insertionOrderNumber{get;set;}
        public String orderId{get;set;}
        public String orderNumber{get;set;}
        public String orderItemNumber{get;set;}
        public OrderItem item{get;set;}
        public String notes{get;set;}
        public String coverDate{get;set;}
        public String contractId{get;set;}
        public boolean match{get;set;}
        public Invoice__c invoice{get;set;}
        public String invoiceName{get{return invoice.Name;}}
        public String invoiceId{get{return invoice.Id;}}
        public String rep{get;set;}
        public String opportunityId;
        public boolean isNotesRow{get;set;}
        public String attachmentId {get;set;}
        public String attachmentName {get;set;}
        public String orderProductDescription{get;set;}


        // production report fields
        public String DOC{get;set;}
        public String MAT{get;set;}
        public String PRQ{get;set;}
        public String POK{get;set;}
        public String setKeyNo{get;set;}
        public String adId{get;set;}

        //for total row where mapping isn't needed
        public RowModel(){}

        //map from order + order item here
        public RowModel(OrderItem orderItem,Map<Id,Invoice__c> invoiceMap, Map<Id, Attachment> parent2attch){
            //ContractOrderMatch com = new ContractOrderMatch(orderItem.Order.ContractId,orderItem.OrderId);
			isTotalRow = false;
			isNotesRow = false;
            opportunityId = orderItem.Order.OpportunityId;
            //Opportunity op = [Select Id, (Select Id, Name from Attachments order by lastmodifieddate desc LIMIT 1)from Opportunity where Id=:opportunityId];
            if(parent2attch.get(opportunityId) != null){
                attachmentId = parent2attch.get(opportunityId).id;

                attachmentName=parent2attch.get(opportunityId).name.remove('.pdf');
                attachmentName = attachmentName.remove('.PDF');
            }
            notes = orderItem.Accounting_Notes__c;
            accountId = orderItem.Order.AccountId;
            advertiser = orderItem.Order.Account.Name;
            advId = orderItem.Order.Account.IMIS_ID__c;
            agency = orderItem.Order.Ad_Agency__r.Name;
            size = orderItem.Size__c;
            space = orderItem.ListPrice;
            color = orderItem.Color__c;
            pages = orderItem.PricebookEntry.Product2.Page_Count__c;
            if (pages != null) pages = pages.setScale(1);
            chg1 = 0;
            position = orderItem.Position__c;
            chg2 = 0;
            bleed = false;
            chg3 = 0;
            totalMedia = orderItem.Total_Price_Formula__c.setScale(2);
            discount = (orderItem.Discount__c == null) ? null :
                orderItem.Discount__c;
            IF (discount != null) discount.format();
            chg4 = orderItem.Discount_Amount__c;
            chg4 = chg4.setScale(2);
            netMedia = orderItem.Adjusted_Price__c;
            grossOrderTotal = orderItem.Total_Price_Formula__c;
            bill = (orderItem.Order.Account_to_Bill__c == 'Ad Agency') ? 'Y' : 'N' ; //verify
            projectNet = orderItem.Adjusted_Price__c;
            contact = orderItem.Order.BillToContact;
            insertionOrderNumber = orderItem.Order.Insertion_Order_Number__c;
            orderNumber = orderItem.Order.OrderNumber;
            item = orderItem;
            orderItemNumber = orderItem.OrderItemNumber;
            coverDate = dateToFormattedString(orderItem.Show_Event_Publication__r.Show_Start_Date__c);
            contractId = orderItem.Order.ContractId;
            orderId = orderItem.OrderId;
            rep = orderItem.Order.Account.Owner.Name;
            match = true;
            invoice = invoiceMap.get(orderItem.Id);
            orderProductDescription = orderItem.PricebookEntry.Product2.Name;
        }
    }
	static RowModel getNotesRow(String notes){
		RowModel result = new RowModel();
		result.isTotalRow = false;
		result.isNotesRow = true;	
		result.notes = notes;
		return result;
	}
    // for sum row
    static RowModel getTotalRow( Id showPublicationId){
        RowModel result = new RowModel();
		result.isTotalRow = true;
		result.space = 0;
        result.pages = 0;
        result.chg1 = 0;
        result.chg2 = 0;
        result.chg3 = 0;
        result.projectNet = 0;
        result.grossOrderTotal = 0;
        result.netMedia = 0;
        result.totalMedia = 0;
        result.chg4 = 0;
        /*
        //iterate over rows and sum
        for(RowModel row : rows){
            if(row.space != null){result.space += row.space;}
            if(row.pages != null){result.pages += row.pages;}
            if(row.chg1  != null){result.chg1 += row.chg1;}
            if(row.chg2  != null){result.chg2 += row.chg2;}
            if(row.chg3  != null){result.chg3 += row.chg3;}
            if(row.totalMedia != null){result.totalMedia += row.totalMedia;}
            if(row.chg4  != null){result.chg4 += row.chg4;}
            if(row.projectNet  != null){result.projectNet += row.projectNet;}
            if(row.grossOrderTotal  != null){result.grossOrderTotal += row.grossOrderTotal;}
            if(row.netMedia  != null){result.netMedia += row.netMedia;}   
        }
		*/
        //need to add chg1, 2, and 3
       
        List<AggregateResult> aggrResults = [Select sum(ListPrice) LiPrice, sum(PricebookEntry.Product2.Page_Count__c) PCount, sum(Total_Price_Formula__c) TPrice,
                                            sum(Discount__c) Disc, sum(Adjusted_Price__c) AdjPrice from OrderItem where Show_Event_Publication__c = :showPublicationId];
        AggregateResult aggrResult = aggrResults[0];
        result.space = (Decimal) aggrResult.get('LiPrice');
        result.pages = (Decimal) aggrResult.get('PCount');
        result.totalMedia = (Decimal) aggrResult.get('TPrice');
        if(result.totalMedia != null)
        	result.totalMedia = result.totalMedia.setScale(2);
        result.chg4 = (Decimal) aggrResult.get('Disc');
        if(result.chg4 != null)
			result.chg4 = result.chg4.setScale(2);
		result.projectNet = (Decimal) aggrResult.get('AdjPrice'); 
        result.grossOrderTotal = (Decimal) aggrResult.get('TPrice');
        result.netMedia = (Decimal) aggrResult.get('AdjPrice');
        return result;
    }

    public static String dateToFormattedString(Date d){
        //String dateFormat = 'MMMMMMMMMMMMMMMM dd yyyy';
        String dateFormat = 'MMM dd yyyy';
        if (d == null) return null;

        Datetime dt = datetime.newInstance(d.year(), d.month(), d.day());
        //return dt.format(dateFormat);
        return dt.format(dateFormat);
    }
}