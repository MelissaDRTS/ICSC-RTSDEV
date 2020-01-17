public class OrderItemTriggerHandler {
    public static void handleBeforeInsert(List<OrderItem> records){
        setGlCodes(records);
    }
    
    public static void handleBeforeUpdate(List<OrderItem> records){
        setGlCodes(records);
    }
    
    static void setGlCodes(List<OrderItem> records){
        for (OrderItem record : records){
            record.Discount_GL_Code__c = DiscountGLCode.getGlCode(record.Discount_Code__c);
        }
    }
}