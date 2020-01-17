public class PaymentDistributionController {
	
	public Account paymentAccount{get;set;}
	public List<Payment__c> payments{get;set;}
	public boolean hNext{get{return hasNext();}set;}
	public boolean hPrev{get{return hasPrevious();}set;}
	public List<OrderItem> orderItemsForDisplay{get{return [Select Id, Balance_Due__c,OrderItemNumber, Show_Event_Publication__r.Id, Show_Event_Publication__r.Name, Pricebookentry.Product2.Name
								from OrderItem where Id In : pages.get(currentPage)
								ORDER BY Balance_Due__c ASC];}set;}
	private Integer lastPage{get;set;}
	private Integer currentPage;
	private Integer PAGE_SIZE = 50;
	private Map<Integer, Set<Id>> pages;
	public Decimal availableAmount{get;set;}
	public List<OrderItem> orderItemList{get;set;}
	public Map<Id, Decimal> orderItem2pay{get;set;}
	private Map<Id, Payment__c> payMap{get;set;}
	private Map<Id, OrderItem> oMap{get;set;}
	public boolean error{get;set;}
	public Decimal totalDue{get;set;}
	public PaymentDistributionController(){
		String accountId = ApexPages.currentPage().getParameters().get('id');
		paymentAccount = [Select Id, Name from Account where Id = :accountId];
		payments = [Select Name,Payment_Amount_Remaining__c, Id From Payment__c Where Account_Name__c = :paymentAccount.Id ORDER BY Payment_Amount_Remaining__c ASC];
		payMap = new Map<Id, Payment__c>();
		orderItemsForDisplay = new List<OrderItem>();
		pages = new Map<Integer, Set<Id>>();
		System.debug(payments);
		error= false;
		currentPage = 0;

		availableAmount = 0;
		totalDue = 0;
		for(Payment__c payment : payments){
			availableAmount += payment.Payment_Amount_Remaining__c;
			payMap.put(payment.Id, payment);
			System.debug(availableAmount);
		}
		availableAmount.setScale(2);
		List<Order> orderList = [Select Id from Order where AccountId = :paymentAccount.Id];
		Set<ID> orderIds = new Set<ID>();
		for(Order o : orderList){
			orderIds.add(o.Id);
		}
		oMap = new Map<Id, OrderItem>();
		orderItemList = [Select Id, Balance_Due__c, OrderItemNumber, Show_Event_Publication__r.Id, Show_Event_Publication__r.Name,  Pricebookentry.Product2.Name 
						from OrderItem where OrderId IN :orderIds AND Balance_Due__c > 0
						ORDER BY Balance_Due__c ASC];
		orderItem2pay = new Map<Id, Decimal>();
		for(OrderItem o : orderItemList){
				orderItem2pay.put(o.Id, 0.0);
				oMap.put(o.Id, o);

		}
		Integer i = 0;
		Boolean done = false;
		if(!orderItemList.isEmpty()){
			while(!done){
				Set<Id> page = new Set<Id>();
				for(Integer j = i * PAGE_SIZE; (j < (i*PAGE_SIZE + PAGE_SIZE) ) && (j < orderItemList.size()); j++){
					page.add(orderItemList.get(j).id);
					if(j == orderItemList.size() - 1){
						done = true;
					}
				}
				pages.put(i, page);
				if(done)
					break;
				else
					i++;
			}
			lastPage = i;
			hNext = hasNext();
			hPrev = hasPrevious();
			updatePage(currentPage);
			getPageOptions();
		}
	}
	private void updatePage(Integer newPage){
		orderItemsForDisplay = [Select Id, Balance_Due__c,OrderItemNumber, Show_Event_Publication__r.Id, Show_Event_Publication__r.Name, Pricebookentry.Product2.Name
								from OrderItem where Id In : pages.get(newPage)
								ORDER BY Balance_Due__c ASC];
		
		System.debug(orderItemsForDisplay);
		System.debug(orderItem2pay);
		for(OrderItem o : orderItemsForDisplay){
			totalDue += o.Balance_Due__c;
		}
        pageSelected = String.valueOf(currentPage);

		hNext = hasNext();
		hPrev = hasPrevious();

	}
	public void last(){
		currentPage = lastPage;
		updatePage(currentPage);
	}
	public void next(){
		if(hNext == true){
			currentPage++;
			updatePage(currentPage);
		}
	}
	public void previous(){
		if(hPrev == true){
			currentPage--;
			updatePage(currentPage);
		}
	}
	public void first(){
		currentPage = 0;
		updatePage(currentPage);
	}
	private boolean hasNext(){
		return (currentPage < lastPage);
	}
	private boolean hasPrevious(){
		return (currentPage > 0);
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
	public void distributePayments(){
		//Clear old values
		error = false;
		for(OrderItem o : orderItemsForDisplay){
			orderItem2pay.put(o.Id, 0.0);
		}

		for(Payment__c payment : payments){
			Decimal paymentRemaining = payment.Payment_Amount_Remaining__c;
			for(OrderItem o : orderItemsForDisplay){
				Decimal paymentTotal = 0;
				if(paymentRemaining > 0 && (o.Balance_Due__c - orderItem2pay.get(o.Id)) > 0){
					if(paymentRemaining >= o.Balance_Due__c - orderItem2pay.get(o.Id)){ //if Amount available is greater than the price remaining
						paymentRemaining = paymentRemaining - (o.Balance_Due__c - orderItem2pay.get(o.Id));
						paymentTotal += o.Balance_Due__c - orderItem2pay.get(o.Id);
						System.debug(paymentRemaining);
						orderItem2pay.put(o.Id, o.Balance_Due__c);
					}
					else{
						System.debug('Payment funds used up for payment:' + payment.Name);
						paymentTotal += paymentRemaining;
						orderItem2pay.put(o.Id, orderItem2pay.get(o.Id) + paymentRemaining);
						paymentRemaining = 0;
					}
				}
			}
		}
		System.debug(orderItem2pay);
	}
	public PageReference saveDistribution(){
		Decimal runningTotal = 0;
		for(Decimal val : orderItem2pay.values()){
			runningTotal += val;
		}
		if(runningTotal > availableAmount){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of payments is greater than available funds. \n Assigned Amount: $' + runningTotal.setScale(2) + 
				'\n Available Amount: $' + availableAmount.setScale(2)));
			error = true;
			return new PageReference('/apex/PaymentDistribution?id=' + ApexPages.currentPage().getParameters().get('id'));

		}
		else{
			List<Applied_Payment__c> apList = new List<Applied_Payment__c>();
			for(Payment__c payment : payments){
				Decimal totalAvail = payment.Payment_Amount_Remaining__c;
				for(Id oId : orderItem2pay.keySet()){
					OrderItem oitem = oMap.get(oId);
					if(orderItem2pay.get(oId) > oitem.Balance_Due__c){
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment amount is greater than balance due. \n   Assigned Amount: $' + orderItem2pay.get(oId).setScale(2) + 
				'\n   Balance Due: $' + oitem.Balance_Due__c));
						error = true;
						return new PageReference('/apex/PaymentDistribution?id=' + ApexPages.currentPage().getParameters().get('id'));
					}
				    else if(orderItem2pay.get(oId) > 0 && totalAvail > 0){
						if(totalAvail <= orderItem2pay.get(oId)){
							apList.add(new Applied_Payment__c(Applied_Date__c = system.today(), Payment__c = payment.Id, Order_Line_Item__c=oId, Applied_Amount__c = totalAvail));
							totalAvail = 0; //no more funds left
							orderItem2pay.put(oId, orderItem2pay.get(oId) - totalAvail); //update balance due
						}
						else{
							apList.add(new Applied_Payment__c(Applied_Date__c = system.today(), Payment__c = payment.Id, Order_Line_Item__c = oId, Applied_Amount__c = orderItem2pay.get(oId)));
							totalAvail -= orderItem2pay.get(oId); //update available funds
							orderItem2pay.put(oId, 0); //no longer need to pay anymore here

						}
					}

				}
			}
			insert apList;
		}
		PageReference p = new PageReference('/apex/PaymentDistribution?id=' + ApexPages.currentPage().getParameters().get('id')); //refresh the page after save
		p.setRedirect(true);
		return p;
	}
	public PageReference apRedirect(){
		return new PageReference('/apex/AppliedPaymentView?id=' + paymentAccount.id);
	}
 }