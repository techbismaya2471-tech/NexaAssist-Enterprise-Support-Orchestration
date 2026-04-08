# Architecture Diagram Text

```text
Customer / External Website / API Client
                ↓
      NexaAssistApiController
                ↓
      NexaAssistOrchestrator
                ↓
         AgentApiService
   (Token + Session + Message API)
                ↓
            Agentforce
                ↓
     Classification + Parsing Layer
                ↓
    Contact Resolution (Email → Contact)
                ↓
 Customer_Insight__c (Simulated Data Cloud)
                ↓
      Enterprise Decision Layer
   - VIP handling
   - Churn risk escalation
   - Health score prioritization
                ↓
      NexaSupportRequestAction
                ↓
   Case / Interaction_Log__c / Queue
                ↓
   Human Support Queue / Final Response