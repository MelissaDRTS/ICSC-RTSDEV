@isTest
public class AppliedPaymentTriggerTest {
	public static TestMethod void insertTest(){
		Account paymentAccount;
		Order ord;
		User admin;

		paymentAccount = new Account(Name = 'Test');
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
		for(Integer i = 0; i < entryList.size(); i++){
			total += entryList[i].UnitPrice * orderItems[i].Quantity;
		}
		
		List<Payment__c> paymentList = new List<Payment__c>();
		Payment__c payment1 = new Payment__c(Payment_Type__c ='Check', Amount_Paid__c = 50000, Account_Name__c = paymentAccount.id);
		paymentList.add(payment1);
		insert payment1;
		Applied_Payment__c appliedPayment = new Applied_Payment__c(Applied_Date__c = system.today(), Payment__c = payment1.Id, Order_Line_Item__c = o1.Id, Applied_Amount__c = 1000);
		insert appliedPayment;

		/*Asserts here*/
		OrderItem newOrderItem = [Select Balance_Due__c, Sum_Of_Applied_Payments__c from OrderItem where id =: o1.id];
		Payment__c newPayment = [Select Payment_Amount_Remaining__c, Amount_Paid__c from Payment__c where id =:payment1.id];
		System.assertEquals(payment1.Amount_Paid__c - appliedPayment.Applied_Amount__c, newPayment.Payment_Amount_Remaining__c);
		System.assertEquals(0, newOrderItem.Balance_Due__c);
		System.assertEquals(appliedPayment.Applied_Amount__c, newOrderItem.Sum_Of_Applied_Payments__c);
	}
	public static TestMethod void deleteTest(){
		Account paymentAccount;
		Order ord;
		User admin;

		paymentAccount = new Account(Name = 'Test');
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
		for(Integer i = 0; i < entryList.size(); i++){
			total += entryList[i].UnitPrice * orderItems[i].Quantity;
		}
		
		List<Payment__c> paymentList = new List<Payment__c>();
		Payment__c payment1 = new Payment__c(Payment_Type__c ='Check', Amount_Paid__c = 50000, Account_Name__c = paymentAccount.id);
		paymentList.add(payment1);
		insert payment1;
		Applied_Payment__c appliedPayment = new Applied_Payment__c(Applied_Date__c = system.today(), Payment__c = payment1.Id, Order_Line_Item__c = o1.Id, Applied_Amount__c = 1000);
		insert appliedPayment;
		delete appliedPayment;
		/*Asserts here*/
		OrderItem newOrderItem = [Select Balance_Due__c, Sum_Of_Applied_Payments__c from OrderItem where id = : o1.id];
		Payment__c newPayment = [Select Payment_Amount_Remaining__c, Amount_Paid__c from Payment__c where id = : payment1.id];
		System.assertEquals(o1.UnitPrice * o1.Quantity, newOrderItem.Balance_Due__c);
		System.assertEquals(newPayment.Amount_Paid__c, newPayment.Payment_Amount_Remaining__c);
	}
}