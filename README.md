# NexaAssist – Enterprise Support Orchestration

Enterprise AI-powered customer support orchestration built with Salesforce Agentforce, Apex, Flow, API integration and future Data Cloud enrichment.

## Key Highlights
- Agentforce-powered conversational support
- Apex-based case orchestration and escalation logic
- Duplicate case prevention and smart escalation
- Human handoff routing with Interaction Logs
- API integration between external website and Salesforce
- Enterprise-ready support flow with category-based routing
- Planned Data Cloud enrichment for unified customer profile, churn risk, adoption score and customer health

## Business Problem
Traditional support systems create duplicate cases, miss escalation context and fail to personalize support.

NexaAssist solves this by:
- Identifying the customer by email first
- Detecting existing open cases
- Escalating duplicate issues instead of creating new cases
- Routing to human support only when needed
- Maintaining conversational context through Interaction_Log__c

## Architecture
1. Customer sends support request
2. Agentforce classifies request
3. Apex parser converts classification JSON
4. Apex orchestration applies enterprise support logic
5. Case is created / updated / escalated
6. Human support routing happens if required
7. Future Data Cloud layer enriches the customer profile

## Project Modules
- `/apex` → Apex classes and orchestrator
- `/flows` → Flow screenshots and export references
- `/prompts` → Agentforce prompts and topic instructions
- `/docs` → Architecture, design and enterprise explanation
- `/datacloud` → Future Data Cloud design
- `/screenshots` → UI, flow and testing screenshots
- `/resume` → Resume bullets and interview explanation

## Enterprise Features
- Smart duplicate-case handling
- Escalation after repeated issue
- Multi-open-case support logic
- Human handoff with clarification
- Technical issue classification (Physical / Remote / Unknown)
- Enterprise-grade security through email revalidation
- Future semantic duplicate detection and Data Cloud enrichment

## Future Enhancements
- Voice input support
- Semantic duplicate detection
- Data Cloud customer health scoring
- Multi-channel support
- RAG-powered knowledge retrieval