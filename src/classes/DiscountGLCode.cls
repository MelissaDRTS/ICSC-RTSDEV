//
// this class is used in combination with the Discount Code global picklist value set and the GL Discount Code Mapping custom metadata type
// to map Discount Code -> Discount GL Code automatically on opportunity line items and order line items
//

public class DiscountGLCode {
    public static String getGlCode(String discountCode){
        List<GL_Discount_Code_Mapping__mdt> mdts = [Select Label, GL_Code__c from GL_Discount_Code_Mapping__mdt where Label = :discountCode];
        if (mdts.size() > 0){
            return mdts[0].GL_Code__c;
        }
        
        return null;
    }
}