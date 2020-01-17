/**
 * Created by Eric Stansbury on 6/7/2018.
 */

trigger OrderTrigger on Order (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert){
        OrderTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate){
        //OrderTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}