@isTest
public class ShowpubRedirectControllerTest {
    public static TestMethod void testController(){
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
        Show_Publications__c shp = new Show_Publications__c(Name='Show');
		insert shp;
		List<OrderItem> orderItems = new List<OrderItem>();
		OrderItem o1 = new OrderItem(PricebookEntryId = standardPrice1.Id, Show_Event_Publication__c=shp.id, OrderId=ord.id, UnitPrice=standardPrice1.UnitPrice, Quantity = 10);
		orderItems.add(o1);
		OrderItem o2 = new OrderItem(PricebookEntryId = standardPrice2.Id, Show_Event_Publication__c=shp.id, OrderId=ord.id, UnitPrice=standardPrice2.UnitPrice, Quantity = 2);
		orderItems.add(o2);
		OrderItem o3 = new OrderItem(PricebookEntryId = standardPrice3.Id, OrderId=ord.id, UnitPrice=standardPrice3.UnitPrice, Quantity = 1);
		orderItems.add(o3);
		insert orderItems;
		Invoice__c invoice1 = new Invoice__c(Product__c = o1.id, Authorized_For_Printing__c = true);
		insert invoice1;
        Invoice__c invoice2 = new Invoice__c(Product__c = o2.id, Authorized_For_Printing__c = true);
		insert invoice2;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(shp);
        System.Test.setCurrentPageReference(new PageReference('/apex/ShowpubRedirectController?id=' + paymentAccount.id));
        ShowpubRedirectController controller = new ShowpubRedirectController(sc);
        controller.next();
        controller.previous();
        controller.first();
        controller.last();
        controller.pageSelected = '0';
        controller.pageSelect();
    }
}