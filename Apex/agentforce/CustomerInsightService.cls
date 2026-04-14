public with sharing class CustomerInsightService {
    public class InsightResult {
        public Boolean hasInsight = false;
        public String segment;
        public Decimal healthScore;
        public String churnRisk;
        public String preferredChannel;

        public Boolean forceEscalation = false;
        public Boolean forceHighPriority = false;
        public Boolean fasterSupportPath = false;
        public String internalInsightNote = '';
        public Decimal adoptionScore;
        public Date lastProductUsageDate;
        public String unifiedCustomerId;
    }

    public static InsightResult fetchInsight(Id contactId) {
        InsightResult result = new InsightResult();

        List<Customer_Insight__c> insights = [
            SELECT Id,
                    Name,
                    Contact__c,
                    Segment__c,
                    Health_Score__c,
                    Churn_Risk__c,
                    Preferred_Channel__c,
                    Adoption_Score__c,
                    Last_Product_Usage_Date__c,
                    Unified_Customer_Id__c
                FROM Customer_Insight__c
            WHERE Contact__c = :contactId
               
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];

        if (insights.isEmpty()) {
            return result;
        }

        Customer_Insight__c insight = insights[0];

        result.hasInsight = true;
        result.segment = insight.Segment__c;
        result.healthScore = insight.Health_Score__c;
        result.churnRisk = insight.Churn_Risk__c;
        result.preferredChannel = insight.Preferred_Channel__c;
        result.adoptionScore = insight.Adoption_Score__c;
        result.lastProductUsageDate = insight.Last_Product_Usage_Date__c;
        result.unifiedCustomerId = insight.Unified_Customer_Id__c;

        List<String> notes = new List<String>();

        if (result.churnRisk == 'High') {
            result.forceEscalation = true;
            result.forceHighPriority = true;
            notes.add('Customer flagged as high churn risk from customer insight profile.');
        }

        if (result.segment == 'VIP' || result.segment == 'Enterprise') {
            result.forceHighPriority = true;
            notes.add('VIP / Enterprise customer detected from unified profile.');
        }

        if (result.healthScore != null && result.healthScore < 40) {
            result.fasterSupportPath = true;
            notes.add('Customer has low health score, so support should move faster.');
        }
        if (result.adoptionScore != null && result.adoptionScore < 30) {
            result.fasterSupportPath = true;
            notes.add('Customer has low adoption score, indicating low product engagement.');
        }

        if (result.preferredChannel != null) {
            notes.add('Preferred support channel: ' + result.preferredChannel + '.');
        }
        if (result.lastProductUsageDate != null) {
            Integer daysSinceUsage = result.lastProductUsageDate.daysBetween(Date.today());
            if (daysSinceUsage > 30) {
                result.fasterSupportPath = true;
                notes.add('Customer has not used the product in ' + daysSinceUsage + ' days.');
            }
    }
    
        result.internalInsightNote = String.join(notes, ' ');
        return result;
    }
}