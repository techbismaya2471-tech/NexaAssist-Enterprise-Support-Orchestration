public with sharing class CustomerInsightTriggerHandler {
   public static void handleCaseChange(Set<Id> contactIds) {
        if (contactIds.isEmpty()) return;
        
        // Step 1: Get all open cases per contact
        Map<Id, Integer> openCaseCount = new Map<Id, Integer>();
        Map<Id, Integer> escalatedCaseCount = new Map<Id, Integer>();
        
        for (AggregateResult ar : [
            SELECT ContactId, COUNT(Id) cnt, Escalated__c
            FROM Case
            WHERE ContactId IN :contactIds
            AND Status != 'Closed'
            GROUP BY ContactId, Escalated__c
        ]) {
            Id conId = (Id) ar.get('ContactId');
            Integer cnt = (Integer) ar.get('cnt');
            Boolean isEscalated = (Boolean) ar.get('Escalated__c');
            
            if (!openCaseCount.containsKey(conId)) {
                openCaseCount.put(conId, 0);
                escalatedCaseCount.put(conId, 0);
            }
            openCaseCount.put(conId, openCaseCount.get(conId) + cnt);
            if (isEscalated == true) {
                escalatedCaseCount.put(conId, escalatedCaseCount.get(conId) + cnt);
            }
        }
        
        // Step 2: Get interaction log count per contact
        Map<Id, Integer> interactionCount = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Contact__c, COUNT(Id) cnt
            FROM Interaction_Log__c
            WHERE Contact__c IN :contactIds
            GROUP BY Contact__c
        ]) {
            interactionCount.put(
                (Id) ar.get('Contact__c'), 
                (Integer) ar.get('cnt')
            );
        }
        
        // Step 3: Get existing Customer_Insight__c records
        Map<Id, Customer_Insight__c> existingInsights = new Map<Id, Customer_Insight__c>();
        for (Customer_Insight__c ci : [
            SELECT Id, Contact__c, Health_Score__c, Churn_Risk__c, 
                   Segment__c, Adoption_Score__c
            FROM Customer_Insight__c
            WHERE Contact__c IN :contactIds
        ]) {
            existingInsights.put(ci.Contact__c, ci);
        }
        
        // Step 4: Calculate scores and update
        List<Customer_Insight__c> toUpsert = new List<Customer_Insight__c>();
        
        for (Id contactId : contactIds) {
            Integer openCases = openCaseCount.containsKey(contactId) ? 
                                openCaseCount.get(contactId) : 0;
            Integer escalated = escalatedCaseCount.containsKey(contactId) ? 
                                escalatedCaseCount.get(contactId) : 0;
            Integer interactions = interactionCount.containsKey(contactId) ? 
                                   interactionCount.get(contactId) : 0;
            
            // Health Score Logic
            Integer healthScore = 100;
            if (openCases == 1) healthScore = 70;
            else if (openCases == 2) healthScore = 50;
            else if (openCases >= 3) healthScore = 30;
            if (escalated >= 1) healthScore = Math.max(healthScore - 20, 10);
            
            // Churn Risk Logic
            String churnRisk = 'Low';
            if (openCases >= 2 || escalated >= 1) churnRisk = 'High';
            else if (openCases == 1 || interactions >= 3) churnRisk = 'Medium';
            
            // Segment Logic
            String segment = 'Normal';
            if (healthScore >= 80) segment = 'VIP';
            else if (healthScore >= 50 && healthScore < 80) segment = 'Normal';
            else if (healthScore >= 30 && healthScore < 50) segment = 'At Risk';
            else segment = 'Low Adoption';
            
            // Adoption Score Logic
            Integer adoptionScore = Math.max(100 - (openCases * 15) - (interactions * 2), 10);
            
            // Build record
            Customer_Insight__c ci = existingInsights.containsKey(contactId) ?
                                     existingInsights.get(contactId) :
                                     new Customer_Insight__c(Contact__c = contactId);
            
            ci.Health_Score__c = healthScore;
            ci.Churn_Risk__c = churnRisk;
            ci.Segment__c = segment;
            ci.Adoption_Score__c = adoptionScore;
            
            toUpsert.add(ci);
        }
        
        if (!toUpsert.isEmpty()) {
            upsert toUpsert;
        }
    }
}