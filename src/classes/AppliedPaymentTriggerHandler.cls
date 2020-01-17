public class AppliedPaymentTriggerHandler {
	public static void handleInsert(Map<Id, Applied_Payment__c> newMap){
		Set<ID> oIDs = new Set<ID>();
		for(Applied_Payment__c payment : newMap.values()){
			oIDs.add(payment.Order_Line_Item__c);
		}
		List<OrderItem> orderItems = [Select Sum_of_Applied_Payments__c, Id From OrderItem where Id in :oIDs];
		Map<Id, OrderItem> oMap = new Map<Id,  OrderItem>();
		System.debug(orderItems);
		for(OrderItem o : orderItems){
			oMap.put(o.Id, o);
		}

		List<OrderItem> updateList = new List<Orderitem>();
		for(Applied_Payment__c payment : newMap.values()){
			OrderItem oItem = oMap.get(payment.Order_Line_Item__c);
			if(oItem != null){
				if(oItem.Sum_of_Applied_Payments__c == null){
					oItem.Sum_of_Applied_Payments__c = 0;
				}
				oItem.Sum_of_Applied_Payments__c += payment.Applied_Amount__c;
				if(payment.Applied_Amount__c != 0){
					updateList.add(oItem);
				}
			}
		}
		update updateList;
	}
	/*
	public static void handleUpdate(Map<Id, Applied_Payment__c> newMap, Map<Id, Applied_Payment__c> oldMap){
		Set<Id> paymentIds = new Set<Id>();
		Set<Id> orderItemIds = new Set<Id>();
		for(Applied_Payment__c nP : newMap.values()){
			if(!paymentIds.contains(nP.Payment__c)){
				paymentIds.add(nP.Payment__c);
			}
			if(!orderItemIds.contains(nP.Order_Line_Item__c)){
				orderItemIds.add(nP.Order_Line_Item__c);
			}
		}
		for(Applied_Payment__c oP : oldMap.values()){
			if(!paymentIds.contains(oP.Payment__c)){
				paymentIds.add(oP.Payment__c);
			}
			if(!orderitemIds.contains(oP.Order_Line_Item__c)){
				orderItemIds.add(oP.Order_Line_Item__c);
			}
		}
		List<OrderItem> orderItems = [Select Sum_of_Applied_Payments__c, Id from OrderItem where id in : orderItemIds];
		List<Payment__c> payments = [Select Payment_Amount_Remaining__c, Id from Payment__c where id in :paymentIds];
		List<OrderItem> oItems2Update = new List<OrderItem>();
		Map<Id, OrderItem> oi2Id = new Map<Id, OrderItem>();
		Map<Id, Payment__c> p2Id = new Map<Id, Payment__c>();
		for(OrderItem o : orderItems){
			oi2Id.put(o.Id, o);
		}
		for(Payment__c p : payments){
			p2Id.put(p.Id, p);
		}
		for(Applied_Payment__c newPayment : newMap.values()){
			Applied_Payment__c oldPayment = oldMap.get(newPayment.id);
			if(oldPayment.Applied_Amount__c != newPayment.Applied_Amount__c){
				Payment__c p = p2Id.get(newPayment.Payment__c);
				OrderItem oItem = oi2Id.get(newPayment.Order_Line_Item__c);
				if(newPayment.Applied_Amount__c > p.Payment_Amount_Remaining__c){
					newPayment.addError('Payment record ' + p.Name + ' does not have enough available funds to apply that amount.');
				}
				if(newPayment.Applied_Amount__c > oItem.Balance_Due__c){
					newPayment.addError('Applied amount ' + newPayment.Applied_Amount__c + ' is greater than the balance due ' + oItem.Balance_Due__c);
				}
				if(oldPayment.Order_Line_Item__c == newPayment.Order_Line_Item__c){
					oItem.Sum_of_Applied_Payments__c -= oldPayment.Applied_Amount__c;
					oItem.Sum_of_Applied_Payments__c += newPayment.Applied_Amount__c;
					Set<OrderItem> oitemsUpdateSet = new Set<OrderItem>(oItems2Update);
					if(!oItemsUpdateSet.contains(oItem)){
						oItems2Update.add(oItem);
					}
				}
			}
			if(oldPayment.Payment__c != newPayment.Payment__c){
				Payment__c p = p2Id.get(newPayment.Payment__c);
				if(p.Payment_Amount_Remaining__c < newPayment.Applied_Amount__c){
					newPayment.addError('Payment record ' + p.Name + ' does not have enough available funds to apply that amount.');
				}
			}
			if(oldPayment.Order_Line_Item__c != newPayment.Order_Line_Item__c){
				OrderItem newOrderitem = oi2Id.get(newPayment.Order_Line_Item__c);
				if(newOrderitem.Balance_Due__c < newPayment.Applied_Amount__c){
					newPayment.addError('Applied amount ' + newPayment.Applied_Amount__c + ' is greater than balance due ' + newOrderItem.Balance_Due__c);
				}
				else{
					OrderItem oldOrderItem = oi2Id.get(oldPayment.Order_Line_Item__c);
					if(newPayment.Applied_Amount__c == oldPayment.Applied_Amount__c){
						oldOrderItem.Sum_of_Applied_Payments__c -= newPayment.Applied_Amount__c;
						newOrderitem.Sum_of_Applied_Payments__c += newPayment.Applied_Amount__c;
					}
					else{
						oldOrderitem.Sum_of_Applied_Payments__c -= oldPayment.Applied_Amount__c;
						newOrderitem.Sum_of_Applied_Payments__c += newPayment.Applied_Amount__c;
					}
					Set<OrderItem> oItemsUpdateSet = new Set<Orderitem>(oItems2Update);
					if(!oItemsUpdateSet.contains(oldOrderitem)){
						oItems2Update.add(oldOrderitem);
					}
					if(!oItemsUpdateSet.contains(newOrderItem)){
						oItems2Update.add(newOrderitem);
					}
				}
			}
		}
		update oItems2Update;
	}
	*/
	public static void handleDelete(Map<Id, Applied_Payment__c> oldMap){
		List<ID> oIDs = new List<ID>();
		for(Applied_Payment__c payment : oldMap.values()){
			oIDs.add(payment.Order_Line_Item__c);
		}
		List<OrderItem> orderItems = [Select Sum_of_Applied_Payments__c, Id From OrderItem where Id in :oIDs];
		Map<Id, OrderItem> oMap = new Map<Id,  OrderItem>();
		for(OrderItem o : orderItems){
			oMap.put(o.Id, o);
		}
		List<OrderItem> updateList = new List<OrderItem>();
		for(Applied_Payment__c payment : oldMap.values()){
			OrderItem oItem = oMap.get(payment.Order_Line_Item__c);
                if(oItem.Sum_Of_Applied_Payments__c == null || oItem.Sum_of_Applied_Payments__c < payment.Applied_Amount__c){
                    oItem.Sum_of_Applied_Payments__c = 0; //prevent  negative values here
                }
                else{
                    oItem.Sum_of_Applied_Payments__c -= payment.Applied_Amount__c;
                }
                updateList.add(oItem);
            
		}
		update updateList;
	}

}