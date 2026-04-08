NexaAssist – Enterprise Support Orchestration Platform
Overview
NexaAssist is an enterprise-style Salesforce support platform built to simulate how real organizations handle customer issues across multiple channels.
The platform uses Salesforce Agentforce, Apex, Omni-Channel, and intelligent case orchestration to:
•	classify customer issues
•	prevent duplicate case creation
•	intelligently escalate unresolved issues
•	route customers to human support when required
•	maintain interaction history across conversations
•	prepare for future customer insights using Data Cloud
This project was designed as a realistic enterprise support solution rather than a simple chatbot demo.
 
Business Problem
In many organizations, support teams face these common problems:
•	customers create duplicate tickets for the same issue
•	unresolved issues are not escalated correctly
•	customers must repeat the same information multiple times
•	support agents do not have complete context
•	there is no intelligent routing between self-service and human support
NexaAssist solves this by creating a support orchestration layer on top of Salesforce.
 
Key Features
Intelligent Case Creation
•	New issue category → create a new case
•	Same category + existing open case → reuse and escalate existing case
•	Different category → create a separate case
Duplicate Case Prevention
•	Prevents duplicate cases for the same customer and issue category
•	Detects repeated requests and escalates instead of creating unnecessary records
Escalation Logic
•	Second request for same issue → existing case escalated
•	Priority automatically changed to High
•	Escalated flag updated
•	Human support workflow triggered
Human Support Routing
•	Direct request for human support routes the issue to the human support queue
•	Supports Omni-Channel and Service Console routing
Multi-Case Handling
•	If the customer already has multiple open issues, the platform intelligently decides: 
o	whether to escalate an existing case
o	whether to create a new case
o	whether to ask the customer which issue they need help with
Interaction Tracking
•	Uses custom Interaction_Log__c records to track: 
o	pending follow-up state
o	clarification requests
o	escalation state
o	human handoff flow
Future Data Cloud Integration
Planned future enhancement:
•	Unified customer profile
•	Customer health score
•	Churn risk
•	Preferred support channel
•	Smarter Agentforce decisions using customer insights
 
High-Level Architecture
Customer / Website / Chat UI
            ↓
       Salesforce Agentforce
            ↓
      Prompt Template Classification
            ↓
     Apex Orchestrator / Business Logic
            ↓
 ┌─────────────────────────────────────┐
 │ Case Creation / Escalation         │
 │ Interaction_Log__c Tracking        │
 │ Human Support Queue Routing        │
 └─────────────────────────────────────┘
            ↓
      Omni-Channel / Service Console

Future:
Data Cloud → Customer Insights → Better Agent Decisions
 
End-to-End Flow
1.	Customer describes an issue
2.	Agentforce classifies the issue category and intent
3.	Customer email is validated and matched to an existing Contact
4.	System checks for existing open cases
5.	Based on business rules: 
o	create a new case
o	escalate an existing case
o	ask for clarification
6.	If needed, route the case to human support
7.	Save interaction state in Interaction_Log__c
8.	Return a customer-friendly response
 
Folder Structure
Apex/        → Apex classes and wrappers
Docs/        → Architecture, flow, and enterprise notes
Flows/       → Flow migration notes and orchestration references
Prompts/     → Prompt templates and classification logic
Datacloud/   → Planned Data Cloud simulation and customer insight model
Resume/      → Interview explanation and resume bullets
 
Why Apex Instead of Only Flow?
The project initially started with Salesforce Flow, but the business logic became increasingly complex.
The solution was migrated to Apex because Apex provides:
•	better debugging
•	deterministic business logic
•	easier handling of complex scenarios
•	better scalability for enterprise use cases
Examples of scenarios that became easier in Apex:
•	duplicate same-category escalation
•	multiple open-case handling
•	human support routing
•	intelligent clarification logic
 
Future Enhancements
•	Data Cloud integration
•	Voice support input
•	Semantic duplicate detection
•	Separate-case override for escalated issues
•	Better recommendation engine using customer history
 
Demo Scenario
Recommended demo order:
1.	Create a brand new issue
2.	Repeat the same issue → show escalation
3.	Create a different issue → show new case creation
4.	Ask for human support → show queue routing
5.	Demonstrate multiple open case handling
6.	Explain future Data Cloud enhancement
 
Technologies Used
•	Salesforce Agentforce
•	Apex
•	Salesforce Flow
•	Omni-Channel
•	Service Console
•	Prompt Templates
•	REST API Integration
•	Planned Salesforce Data Cloud
 
Author
Built as an enterprise-style portfolio and interview project focused on Salesforce support automation, orchestration, and AI-assisted service workflows.

