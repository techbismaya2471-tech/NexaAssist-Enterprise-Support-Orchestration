# Interview Explanation

NexaAssist is an enterprise support orchestration platform, not just a chatbot.

The main problem I wanted to solve was that traditional support systems create duplicate tickets, lose customer context and escalate too late.

I designed NexaAssist so that:
- The customer is identified first through email
- Existing open cases are checked before creating a new one
- Repeated issues escalate the existing case instead of creating duplicates
- Human support is triggered only when required
- Customer context is preserved through Interaction_Log__c

Initially, I used Salesforce Flow, but as the logic became more enterprise-level, especially for duplicate handling and multiple open cases, I migrated the core orchestration into Apex.

This gave me:
- Better debugging
- Cleaner architecture
- Easier future enhancements
- More reliable Agentforce integration

In the future, I plan to integrate Salesforce Data Cloud to enrich support decisions using health score, churn risk, preferred channel and unified customer profile.