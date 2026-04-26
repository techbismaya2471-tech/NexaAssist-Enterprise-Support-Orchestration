trigger CustomerInsightTrigger on Case (after insert, after update) {
    
    Set<Id> contactIds = new Set<Id>();
    
    for (Case c : Trigger.new) {
        if (c.ContactId != null) {
            contactIds.add(c.ContactId);
        }
    }
    
    if (!contactIds.isEmpty()) {
        CustomerInsightTriggerHandler.handleCaseChange(contactIds);
    }
}