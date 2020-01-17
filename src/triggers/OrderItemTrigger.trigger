trigger OrderItemTrigger on OrderItem (before insert, before update) {
    if (Trigger.isBefore){
        if(Trigger.isInsert){
            OrderItemTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){
            OrderItemTriggerHandler.handleBeforeUpdate(Trigger.new);
        }
    }
}