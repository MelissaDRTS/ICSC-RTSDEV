public with sharing class AppliedPaymentViewController {
	private Map<Integer, Set<Id>> pages;
	private Integer currentPage;
	private Integer lastPage;
	private static Integer PAGE_SIZE = 50;
	private Set<ID> paymentIds;
	public List<DisplayRow> rows{get;set;}
	private List<Applied_Payment__c> appliedPaymentsForDisplay{get;set;}
	private List<Applied_Payment__c> appliedPayments;
	public Id paymentAccountId{get;set;}
	public Account paymentAccount{get;set;}
	public boolean hNext{get;set;}
	public boolean hPrev{get;set;}
	public boolean showFilter{get;set;}
	public Date beginDate{get;set;}
	public Date endDate{get;set;}
	private boolean filtered;
	public AppliedPaymentViewController() {
		paymentIds = new Set<Id>();
		showFilter = false;
		filtered = false;
		rows = new List<DisplayRow>();
		pages = new Map<Integer, Set<Id>>();
		paymentAccountId = ApexPages.currentPage().getParameters().get('id');
		paymentAccount = [Select Name from Account where Id = :paymentAccountId];
		List<Payment__c> payments = [Select Id from Payment__c where Account_Name__c =:paymentAccountId];
		for(Payment__c p : payments){
			paymentIds.add(p.Id);
		}
		appliedPayments = [Select Order_Line_Item__c, Id from Applied_Payment__c where Payment__c in :paymentIds];
		Set<Id> orderItemIds = new Set<Id>();
		Map<String, Integer> orderItem2Index = new Map<String, Integer>();
		for(Integer i = 0; i < appliedPayments.size(); i++){
			orderItemIds.add(appliedPayments[i].Order_Line_Item__c);
		}
		List<OrderItem> orderItems = [Select OrderItemNumber, OrderId, Id from OrderItem where id in : orderItemIds];
		Set<String> orderItemNumbers = new Set<String>();
		for(Integer i = 0; i < orderItems.size(); i++){
			orderItemNumbers.add(orderItems[i].OrderItemNumber);
			orderitem2Index.put(orderItems[i].OrderItemNumber, i);
		}
		System.debug(orderItemNumbers);
		List<Invoice__c> paidInvoices = [Select OrderItem_Number__c, Id from Invoice__c where OrderItem_Number__c in : orderitemNumbers AND Paid_in_GP__c = true];
		if(!paidInvoices.isEmpty()){
			//If some of these payments are already paid off invoices, remove them from display
			for(Invoice__c i : paidInvoices){
				appliedPayments.remove(orderitem2Index.get(i.OrderItem_Number__c)); //remove the corresponding payment to that invoice/order item
			}
		}
		boolean done = false;
		Integer i = 0;
		currentPage = 0;
		if(!appliedPayments.isEmpty()){
			while(!done){
				Set<Id> page = new Set<Id>();
				for(Integer j = i*PAGE_SIZE; j<(i*PAGE_SIZE + PAGE_SIZE) && j<appliedPayments.size(); j++){
					page.add(appliedPayments.get(j).id);
					if(j == appliedPayments.size() - 1){
						done = true;
					}	
				}
				pages.put(i, page);
					if(done)
						break;
					else
						i++;
			}
		}
		lastPage = i;
		updatePage(currentPage);
		getPageOptions();
	}
	private boolean hasNext(){
		return currentPage < lastPage;
	}
	private boolean hasPrevious(){
		return currentPage > 0;
	}
	public void next(){
		if(hNext){
			currentPage++;
			updatePage(currentPage);
		}
	}
	public void previous(){
		if(hPrev){
			currentPage--;
			updatePage(currentPage);
		}
	}
	public void first(){
		currentPage = 0;
		updatePage(currentPage);
	}
	public void last(){
		currentPage = lastPage;
		updatePage(currentPage);
	}
	public void updatePage(Integer newPage){
		appliedPaymentsForDisplay = [Select Name, Id, Applied_Date__c, Payment__c, Order_Line_Item__c, Applied_Amount__c 
										from Applied_Payment__c where id in : pages.get(newPage)];
		getDisplayRows();
		hNext = hasNext();
		hPrev = hasPrevious();
	}
	private void getDisplayRows(){
		rows.clear();
		Set<Id> pIds = new Set<Id>();
		Set<Id> oItemIDs = new Set<Id>();

		for(Applied_Payment__c ap : appliedPaymentsForDisplay){
			pIds.add(ap.Payment__c);
			oItemIDs.add(ap.Order_Line_Item__c);
		}
		List<Payment__c> payments = [Select Name, Id from Payment__c where id in : pIds];
		List<OrderItem> orderItems = [Select PricebookEntry.Product2.Name, Id from OrderItem where id in : oItemIDs];
		Map<Id, Payment__c> pMap = new Map<Id, Payment__c>();
		Map<Id, OrderItem> oMap = new Map<Id, OrderItem>();
		for(Payment__c p : payments){
			pMap.put(p.Id, p);
		}
		for(OrderItem o : orderItems){
			oMap.put(o.Id, o);
		}
		for(Applied_Payment__c ap : appliedPaymentsForDisplay){
			rows.add(new DisplayRow(ap, pMap.get(ap.Payment__c), oMap.get(ap.Order_Line_Item__c), ap.Applied_Amount__c, rows.size()));
		}
	}
	public List<SelectOption> pageNumbers{get;set;}
	public String pageSelected{get;set;}
	public void getPageOptions(){
		pageNumbers = new List<SelectOption>();
		for(Integer i = 1; i < lastPage + 2; i++){
			pageNumbers.add(new SelectOption(String.valueOf(i-1), String.valueOf(i)));
		}
		pageSelected = '0';
	}
	public void pageSelect(){
		currentPage = Integer.valueOf(pageSelected);
		updatePage(currentPage);
	}
	public Integer indexToDelete{get;set;}
	public PageReference deleteRow(){
		System.debug(indexToDelete);
		Applied_Payment__c ap = rows.get(indexToDelete).appliedPayment;
		delete ap;
		rows.remove(indexToDelete);
		if(rows.size() == 0){
			//if there are no more rows here
			PageReference p = new PageReference('/apex/AppliedPaymentView?id=' + ApexPages.currentPage().getParameters().get('id'));
			p.setRedirect(true);
			return p;
		}
		else{
			updatePage(currentPage);
			return null;
		}
	}
	public void popupFilter(){
		beginDate = null;
		endDate = null;
		showFilter=true;
	}
	public void filterByDates(){
		pages.clear();
		showFilter = false;
		appliedPayments = [Select Order_Line_Item__c, Id from Applied_Payment__c where Payment__c in :paymentIds 
							AND Applied_Date__c >= :beginDate 
							AND Applied_Date__c <= :endDate];
		Set<Id> orderItemIds = new Set<Id>();
		Map<String, Integer> orderItem2Index = new Map<String, Integer>();
		for(Integer i = 0; i < appliedPayments.size(); i++){
			orderItemIds.add(appliedPayments[i].Order_Line_Item__c);
		}
		List<OrderItem> orderItems = [Select OrderItemNumber, OrderId, Id from OrderItem where id in : orderItemIds];
		Set<String> orderItemNumbers = new Set<String>();
		for(Integer i = 0; i < orderItems.size(); i++){
			orderItemNumbers.add(orderItems[i].OrderItemNumber);
			orderitem2Index.put(orderItems[i].OrderItemNumber, i);
		}
		System.debug(orderItemNumbers);
		List<Invoice__c> paidInvoices = [Select OrderItem_Number__c, Id from Invoice__c where OrderItem_Number__c in : orderitemNumbers AND Paid_in_GP__c = true];
		if(!paidInvoices.isEmpty()){
			//If some of these payments are already paid off invoices, remove them from display
			for(Invoice__c i : paidInvoices){
				appliedPayments.remove(orderitem2Index.get(i.OrderItem_Number__c)); //remove the corresponding payment to that invoice/order item
			}
		}
		boolean done = false;
		Integer i = 0;
		currentPage = 0;
		if(!appliedPayments.isEmpty()){
			while(!done){
				Set<Id> page = new Set<Id>();
				for(Integer j = i*PAGE_SIZE; j<(i*PAGE_SIZE + PAGE_SIZE) && j<appliedPayments.size(); j++){
					page.add(appliedPayments.get(j).id);
					if(j == appliedPayments.size() - 1){
						done = true;
					}	
				}
				pages.put(i, page);
					if(done)
						break;
					else
						i++;
			}
		}
		lastPage = i;
		updatePage(currentPage);
		getPageOptions();
	}
	/*Wrapper class for Applied Payment data*/
	public class DisplayRow{
		public Applied_Payment__c appliedPayment{get;set;}
		public Payment__c payment{get;set;}
		public OrderItem oItem{get;set;}
		public Decimal appliedAmount{get;set;}
		public Integer index{get;set;}
		public String apDate{get;set;}
		public DisplayRow(Applied_Payment__c ap, Payment__c p, OrderItem o, Decimal amount, Integer i){
			appliedPayment = ap;
			payment = p;
			oItem = o;
			appliedAmount = amount;
			index = i;
			apDate = ap.Applied_Date__c.format();
		}
	}
}