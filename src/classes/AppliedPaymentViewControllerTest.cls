@isTest
public class AppliedPaymentViewControllerTest {
	public static TestMethod void singleDeleteTest(){
		Account paymentAccount;
		Order ord;
		User admin;

		Profile adminProfile = [Select Id, Name from Profile where name='System Administrator' limit 1];
		paymentAccount = new Account(Name = 'Test');
		admin = [Select Id, Name from User where ProfileId = :adminProfile.Id AND IsActive = true limit 1];
		insert paymentAccount;
		
		Decimal total = 0;
		List<Product2> productList = new List<Product2>();
		Product2 product1 = new Product2(Name = 'Product 1');
		productList.add(product1);
		Product2 product2 = new Product2(Name = 'Product 2');
		productList.add(product2);
		Product2 product3 = new Product2(Name ='Product 3');
		productList.add(product3);
		insert productList;
		Id standardPricebookId = Test.getStandardPricebookId();
		List<PricebookEntry> entryList = new List<PricebookEntry>();
		PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product1.Id, UnitPrice = 100.00);
		entryList.add(standardPrice1);
		PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product2.Id, UnitPrice = 5000.00);
		entryList.add(standardPrice2);
		PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product3.Id, UnitPrice = 200.00);
		entryList.add(standardPrice3);
		/*More order items */
		ord = new Order(AccountId = paymentAccount.id, Pricebook2Id=standardPricebookId, EffectiveDate = System.today(), Status='Draft');
		insert ord;
		insert entryList;
		
		List<OrderItem> orderItems = new List<OrderItem>();
		OrderItem o1 = new OrderItem(PricebookEntryId = standardPrice1.Id, OrderId=ord.id, UnitPrice=standardPrice1.UnitPrice, Quantity = 10);
		orderItems.add(o1);
		OrderItem o2 = new OrderItem(PricebookEntryId = standardPrice2.Id, OrderId=ord.id, UnitPrice=standardPrice2.UnitPrice, Quantity = 2);
		orderItems.add(o2);
		OrderItem o3 = new OrderItem(PricebookEntryId = standardPrice3.Id, OrderId=ord.id, UnitPrice=standardPrice3.UnitPrice, Quantity = 1);
		orderItems.add(o3);
		insert orderItems;
		Invoice__c invoice1 = new Invoice__c(Product__c = o1.id);
		List<Payment__c> paymentList = new List<Payment__c>();
		Payment__c payment1 = new Payment__c(Payment_Type__c ='Check', Amount_Paid__c = 50000, Account_Name__c = paymentAccount.id);
		paymentList.add(payment1);
		insert payment1;
		List<Applied_Payment__c> appliedPayments = new List<Applied_Payment__c>();
		Applied_Payment__c ap1 = new Applied_Payment__c(Order_Line_Item__c= o1.id, Payment__c = payment1.id, Applied_Amount__c = 1000, Applied_Date__c = System.today());
		appliedPayments.add(ap1);
		insert appliedPayments;
		Test.setCurrentPageReference(Page.AppliedPaymentView);
		System.currentPageReference().getParameters().put('id', paymentAccount.Id);

		AppliedPaymentViewController controller = new AppliedPaymentViewController();
		
		controller.popupFilter();
		controller.beginDate = system.today().addDays(-1);
		controller.endDate = system.today();
		controller.filterByDates();

		controller = new AppliedPaymentViewController();
		System.debug(controller.rows);
		System.assert(controller.rows.size() == 1);
		controller.indexToDelete = 0;
		controller.deleteRow();
		System.assert(controller.rows.size() == 0);
	}
	public static TestMethod void multiDeleteTest(){
		Account paymentAccount;
		Order ord;
		User admin;

		Profile adminProfile = [Select Id, Name from Profile where name='System Administrator' limit 1];
		paymentAccount = new Account(Name = 'Test');
		admin = [Select Id, Name from User where ProfileId = :adminProfile.Id AND IsActive = true limit 1];
		insert paymentAccount;
		
		Decimal total = 0;
		List<Product2> productList = new List<Product2>();
		Product2 product1 = new Product2(Name = 'Product 1');
		productList.add(product1);
		Product2 product2 = new Product2(Name = 'Product 2');
		productList.add(product2);
		Product2 product3 = new Product2(Name ='Product 3');
		productList.add(product3);
		insert productList;
		Id standardPricebookId = Test.getStandardPricebookId();
		List<PricebookEntry> entryList = new List<PricebookEntry>();
		PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product1.Id, UnitPrice = 100.00);
		entryList.add(standardPrice1);
		PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product2.Id, UnitPrice = 5000.00);
		entryList.add(standardPrice2);
		PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product3.Id, UnitPrice = 200.00);
		entryList.add(standardPrice3);
		/*More order items */
		ord = new Order(AccountId = paymentAccount.id, Pricebook2Id=standardPricebookId, EffectiveDate = System.today(), Status='Draft');
		insert ord;
		insert entryList;
		
		List<OrderItem> orderItems = new List<OrderItem>();
		OrderItem o1 = new OrderItem(PricebookEntryId = standardPrice1.Id, OrderId=ord.id, UnitPrice=standardPrice1.UnitPrice, Quantity = 10);
		orderItems.add(o1);
		OrderItem o2 = new OrderItem(PricebookEntryId = standardPrice2.Id, OrderId=ord.id, UnitPrice=standardPrice2.UnitPrice, Quantity = 2);
		orderItems.add(o2);
		OrderItem o3 = new OrderItem(PricebookEntryId = standardPrice3.Id, OrderId=ord.id, UnitPrice=standardPrice3.UnitPrice, Quantity = 1);
		orderItems.add(o3);
		insert orderItems;
		Invoice__c invoice1 = new Invoice__c(Product__c = o1.id);
		List<Payment__c> paymentList = new List<Payment__c>();
		Payment__c payment1 = new Payment__c(Payment_Type__c ='Check', Amount_Paid__c = 50000, Account_Name__c = paymentAccount.id);
		paymentList.add(payment1);
		insert payment1;
		List<Applied_Payment__c> appliedPayments = new List<Applied_Payment__c>();
		Applied_Payment__c ap1 = new Applied_Payment__c(Order_Line_Item__c= o1.id, Payment__c = payment1.id, Applied_Amount__c = 1000, Applied_Date__c = System.today());
		appliedPayments.add(ap1);
		Applied_Payment__c ap2 = new Applied_Payment__c(Order_Line_Item__c= o2.id, Payment__c = payment1.id, Applied_Amount__c = 10000, Applied_Date__c = Date.newInstance(2016, 5, 1));
		appliedPayments.add(ap2);
		insert appliedPayments;
		Test.setCurrentPageReference(Page.AppliedPaymentView);
		System.currentPageReference().getParameters().put('id', paymentAccount.Id);

		AppliedPaymentViewController controller = new AppliedPaymentViewController();
		
		controller.popupFilter();
		controller.beginDate = system.today().addDays(-1);
		controller.endDate = system.today();
		controller.filterByDates();
		System.assert(controller.rows.size() == 1); //this should filter out applied payment 2
		controller = new AppliedPaymentViewController();
		System.debug(controller.rows);
		System.assert(controller.rows.size() == 2);
		controller.indexToDelete = 0;
		controller.deleteRow();
		System.assert(controller.rows.size() == 1);		
	}
	public static TestMethod void checkInvoice(){
		Account paymentAccount;
		Order ord;
		User admin;

		Profile adminProfile = [Select Id, Name from Profile where name='System Administrator' limit 1];
		paymentAccount = new Account(Name = 'Test');
		admin = [Select Id, Name from User where ProfileId = :adminProfile.Id AND IsActive = true limit 1];
		insert paymentAccount;
		
		Decimal total = 0;
		List<Product2> productList = new List<Product2>();
		Product2 product1 = new Product2(Name = 'Product 1');
		productList.add(product1);
		Product2 product2 = new Product2(Name = 'Product 2');
		productList.add(product2);
		Product2 product3 = new Product2(Name ='Product 3');
		productList.add(product3);
		insert productList;
		Id standardPricebookId = Test.getStandardPricebookId();
		List<PricebookEntry> entryList = new List<PricebookEntry>();
		PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product1.Id, UnitPrice = 100.00);
		entryList.add(standardPrice1);
		PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product2.Id, UnitPrice = 5000.00);
		entryList.add(standardPrice2);
		PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product3.Id, UnitPrice = 200.00);
		entryList.add(standardPrice3);
		/*More order items */
		ord = new Order(AccountId = paymentAccount.id, Pricebook2Id=standardPricebookId, EffectiveDate = System.today(), Status='Draft');
		insert ord;
		insert entryList;
		
		List<OrderItem> orderItems = new List<OrderItem>();
		OrderItem o1 = new OrderItem(PricebookEntryId = standardPrice1.Id, OrderId=ord.id, UnitPrice=standardPrice1.UnitPrice, Quantity = 10);
		orderItems.add(o1);
		OrderItem o2 = new OrderItem(PricebookEntryId = standardPrice2.Id, OrderId=ord.id, UnitPrice=standardPrice2.UnitPrice, Quantity = 2);
		orderItems.add(o2);
		OrderItem o3 = new OrderItem(PricebookEntryId = standardPrice3.Id, OrderId=ord.id, UnitPrice=standardPrice3.UnitPrice, Quantity = 1);
		orderItems.add(o3);
		insert orderItems;
		Invoice__c invoice1 = new Invoice__c(Product__c = o1.id, Paid_in_GP__c = true);
		insert invoice1;

		List<Payment__c> paymentList = new List<Payment__c>();
		Payment__c payment1 = new Payment__c(Payment_Type__c ='Check', Amount_Paid__c = 50000, Account_Name__c = paymentAccount.id);
		paymentList.add(payment1);
		insert payment1;
		List<Applied_Payment__c> appliedPayments = new List<Applied_Payment__c>();
		Applied_Payment__c ap1 = new Applied_Payment__c(Order_Line_Item__c= o1.id, Payment__c = payment1.id, Applied_Amount__c = 1000, Applied_Date__c = System.today());
		appliedPayments.add(ap1);
		insert appliedPayments;
		Test.setCurrentPageReference(Page.AppliedPaymentView);
		System.currentPageReference().getParameters().put('id', paymentAccount.Id);
		AppliedPaymentViewController controller = new AppliedPaymentViewController();
		System.assertEquals(0, controller.rows.size()); //the controller should ignore ap1 since the corresponding invoice has been paid in GP
		controller.popupFilter();
		controller.beginDate = system.today().addDays(-1);
		controller.endDate = system.today();
		controller.filterByDates();
		System.assertEquals(0, controller.rows.size());
		

	}
	public static TestMethod void callUIFunctions(){
		Account paymentAccount = new Account(Name = 'Test');
		insert paymentAccount;
		Test.setCurrentPageReference(Page.AppliedPaymentView);
		System.currentPageReference().getParameters().put('id', paymentAccount.Id);
		AppliedPaymentViewController controller = new AppliedPaymentViewController();
		Test.startTest();
		controller.next();
		controller.previous();
		controller.first();
		controller.last();
		controller.pageSelected = '0';
		controller.pageSelect();
		Test.stopTest();
	}
}