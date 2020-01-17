/**
 * Created by Eric Stansbury on 6/11/2018.
 */

global class ICSCOpportunityConverter implements RTSLabs.IOpportunityConverter{
    public static Id createOrder(Id selectedContractId, Opportunity opportunity, Account account) {
        System.debug('ICSCOpportunityConverter createOrder()');

        List<RTSLabs__Opp2Order_Field_Mapping__c> oppOrderMapping = [Select Id, Name, RTSLabs__Destination_Field__c, RTSLabs__Source_Field__c, RTSLabs__Destination_Object__c, RTSLabs__Source_Object__c
        from RTSLabs__Opp2Order_Field_Mapping__c
        where RTSLabs__Source_Object__c = 'opportunity'
        and   RTSLabs__Destination_Object__c = 'order'];

        List<RTSLabs__Opp2Order_Field_Mapping__c> oppItemOrderItemMapping = [Select Id, Name, RTSLabs__Destination_Field__c, RTSLabs__Source_Field__c, RTSLabs__Destination_Object__c, RTSLabs__Source_Object__c
        from RTSLabs__Opp2Order_Field_Mapping__c
        where RTSLabs__Source_Object__c = 'opportunitylineitem'
        and   RTSLabs__Destination_Object__c = 'orderitem'];

        Map <String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String contractLabel = gd.get('Contract').getDescribe().getLabel();
        String orderLabel = gd.get('Order').getDescribe().getLabel();
        String opportunityLabel = gd.get('Opportunity').getDescribe().getLabel();
        String accountLabel = gd.get('Account').getDescribe().getLabel();

        System.debug('createOrder() called !');
        if (selectedContractId == null){
            throw new Opp2OrderException('Please select a contract to associate with the order.');
        }
        if (opportunity == null){
            throw new Opp2OrderException('No opportunity selected.');
        }
        if(account == null) {
            throw new Opp2OrderException('No account selected.');
        }

        Order order = new Order();
        System.debug('mapping opp -> order');
        for (RTSLabs__Opp2Order_Field_Mapping__c mapping : oppOrderMapping){
            try{
                order.put(mapping.RTSLabs__Destination_Field__c, opportunity.get(mapping.RTSLabs__Source_Field__c));
            }catch(Exception e){
                throw new Opp2OrderException('Field mapping error from Opportunity '+mapping.RTSLabs__Source_Field__c+' to Order '+mapping.RTSLabs__Destination_Field__c+': '+e.getMessage());
            }
        }

        //set defaults if null
        if (String.isBlank(order.Status)) order.Status = 'Draft';
        if (order.EffectiveDate == null) order.EffectiveDate = Date.Today();

        //check for invalid dates
        System.debug('retrieving contract');
        Contract selContract = [Select Id, StartDate from Contract where Id = :selectedContractId];
        System.debug('contract retrieved: '+selContract);
        if (order.EffectiveDate < selContract.StartDate){
            String errorMessage = 'Error: '+orderLabel+' start date is earlier than '+contractLabel.toLowerCase()+' start date. Please choose another '+contractLabel.toLowerCase()+'.';
            throw new Opp2OrderException(errorMessage);
        }

        Savepoint savePoint = Database.setSavepoint();

        System.debug('mapping contract -> order');
        boolean contractFieldCopySuccess = copyContractFields(selectedContractId, order,true); // this method catches its own exceptions so do it outside the try block
        if (!contractFieldCopySuccess) return null;

        boolean orderAndOrderItemsSuccess = true;

        // iterate over oppItems and get a set of Show/Publication IDs -- each show will correspond to one order
        String oppLineItemFieldList = '';
        for (String field : Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().fields.getMap().keySet()){
            oppLineItemFieldList += field+', ';
        }

        String oppId = opportunity.Id;
        List<OpportunityLineItem> opportunityLineItems = Database.query('Select '+oppLineItemFieldList+'Product2.Family, PricebookEntry.UnitPrice, PricebookEntry.Pricebook2Id From OpportunityLineItem where OpportunityId = :oppId');

        System.debug('opportunityLineItems');
        System.debug(opportunityLineItems);

        Set<Id> showIds = new Set<Id>();
        for (OpportunityLineItem lineItem : opportunityLineItems){
            showIds.add(lineItem.Show_Event_Publication__c);
        }

        // get the show records so we can use the insertion dates
        List<Order> ordersToInsert = new List<Order>();

        Map<Id,Show_Publications__c> showPubs = new Map<Id, Show_Publications__c>([Select Id, Show_Start_Date__c from Show_Publications__c where Id in :showIds]);

        System.debug('Found '+showIds.size()+' show/pub IDs on these opplineitems');

        try {
            List<OrderItem> lineItemsToInsert = new List<OrderItem>();

            for (Id showId : showIds){
                Date startDate;

                if (showId == null){
                    startDate = Date.today();
                }else{
                    startDate = showPubs.get(showId).Show_Start_Date__c;
                }

                Order thisOrder = order.clone(); // clone from our base order to create an order for each show
                thisOrder.Insertion_Date__c = startDate;
                insert thisOrder;

                List<OpportunityLineItem> thisShowLineItems = getLineItemsForShow(opportunityLineItems, showId);
                lineItemsToInsert.addAll(
                        createOrderItemsFromOpportunity(thisOrder, opportunity, oppItemOrderItemMapping, thisShowLineItems)
                );
            }
            insert lineItemsToInsert;

            opportunity.RTSLabs__Conversion_Date__c = Date.Today();
            opportunity.ContractId = selectedContractId;
            update(opportunity);
        }catch(Exception e){
            System.debug('caught exception '+e.getTypeName()+' '+e.getMessage());
            Database.rollback(savePoint);
            throw new Opp2OrderException(e);
        }
        return opportunity.Id; // opp2order expects a single order ID to redirect to -- since we're making multiple orders, just go back to the opportunity we started with
    }

    public static List<OpportunityLineItem> getLineItemsForShow(List<OpportunityLineItem> allLineItems, Id showPubId){
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (OpportunityLineItem lineItem : allLineItems){
            if (lineItem.Show_Event_Publication__c == showPubId){
                lineItems.add(lineItem);
            }
        }

        return lineItems;
    }

    private static boolean copyContractFields(Id selectedContractId, Order order, boolean addPageMessages) {
        List<RTSLabs__Opp2Order_Field_Mapping__c> contractOrderMapping = [Select Id, Name, RTSLabs__Destination_Field__c, RTSLabs__Source_Field__c, RTSLabs__Destination_Object__c, RTSLabs__Source_Object__c
        from RTSLabs__Opp2Order_Field_Mapping__c
        where RTSLabs__Source_Object__c = 'contract'
        and   RTSLabs__Destination_Object__c = 'order'];

        boolean success = true;
        if (selectedContractId == null) throw new Opp2OrderException('selectedContractId is null');

        //build the query string
        String fieldList = 'Id';
        for (RTSLabs__Opp2Order_Field_Mapping__c mapping : contractOrderMapping){
            if (fieldList.toLowerCase().indexOf(mapping.RTSLabs__Source_Field__c.toLowerCase()) == -1) //avoid duplicating fields
                fieldList+=', '+mapping.RTSLabs__Source_Field__c;
        }
        String queryString = 'Select '+fieldList+' from Contract where Id =\''+selectedContractId+'\'';
        Contract contract = Database.query(queryString);

        //map fields
        for (RTSLabs__Opp2Order_Field_Mapping__c mapping : contractOrderMapping){
            try{
                order.put(mapping.RTSLabs__Destination_Field__c, contract.get(mapping.RTSLabs__Source_Field__c));
            }catch(Exception e){
                String errorMessage = 'Field mapping error from Contract '+mapping.RTSLabs__Source_Field__c+' to Order '+mapping.RTSLabs__Destination_Field__c+': '+e.getMessage();
                System.debug('errorMessage: '+errorMessage);
                //order.addError(errorMessage);
                if (addPageMessages) {
                    ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage)
                    );
                }else{
                    System.debug(errorMessage);
                }
                success = false;
            }
        }
        return success;
    }

    public static List<OrderItem> createOrderItemsFromOpportunity(Order order, Opportunity opportunity, List<RTSLabs__Opp2Order_Field_Mapping__c> oppItemOrderItemMappings, List<OpportunityLineItem> lineItems) {
        String oppId = opportunity.Id;
        List<RTSLabs__Product_Family_Filter_Setting__c> queryRow = [Select RTSLabs__Selected_Families__c from RTSLabs__Product_Family_Filter_Setting__c Limit 1];
        RTSLabs__Product_Family_Filter_Setting__c setting;
        if(!queryRow.isEmpty()){
            setting = queryRow[0];
        }
        else{
            setting = null;
        }
        Set<String> filteredFamilies = (setting == null)? new Set<String>() : new Set<String>(setting.RTSLabs__Selected_Families__c.split(','));
        List<OrderItem> orderItems = new List<OrderItem>();
        Integer i = 0;
        //TODO: expand query to select all fields
        System.debug('lineItems '+lineItems.size());
        for(OpportunityLineItem oppLineItem : lineItems) {
            if(filteredFamilies.isEmpty() || filteredFamilies.contains(oppLineItem.Product2.Family)){
                System.debug('opportunityLineItems '+oppLineItem.PricebookEntry);
                i++;
                if(i==1) {
                    order.Pricebook2Id = oppLineItem.PricebookEntry.Pricebook2Id;
                    update(order);
                }
                /*
                * Creating order item for each pricebook entry
                */
                OrderItem orderItem = new OrderItem();
                orderItem.OrderId = order.Id;
                for (RTSLabs__Opp2Order_Field_Mapping__c mapping : oppItemOrderItemMappings){
                    orderItem.put(mapping.RTSLabs__Destination_Field__c, oppLineItem.get(mapping.RTSLabs__Source_Field__c));
                }
                orderItems.add(orderItem);
            }
        }
        return orderItems;
    }

    class Opp2OrderException extends Exception{}
}