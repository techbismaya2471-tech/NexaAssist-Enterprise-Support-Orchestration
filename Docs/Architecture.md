# NexaAssist Architecture

# High-Level Architecture

External Website / Chat UI
        ↓
Salesforce API Layer (Apex REST)
        ↓
Agentforce Topic + Prompt Template
        ↓
Apex Classification Parser
        ↓
Contact Resolution (Email → Contact)
        ↓
Customer_Insight__c (Simulated Data Cloud Layer)
        ↓
Enterprise Decision Layer
  - VIP Customer Handling
  - High Churn Risk Escalation
  - Health Score Based Prioritization
        ↓
Apex Support Orchestrator
        ↓
Case / Interaction_Log__c
        ↓
Human Support Queue / Omni-Channel

## Core Components
- Agentforce for conversational understanding
- Apex Invocable Action for deterministic business logic
- Interaction_Log__c for conversation state management
- Case escalation logic with duplicate prevention
- Omni-Channel queue routing for human support

## Why Apex Instead of Only Flow
The original implementation used Flow, but the project moved core business logic into Apex because:
- Complex duplicate handling became difficult in Flow
- Multi-open-case logic caused versioning and branching issues
- Apex provides easier debugging, maintainability and enterprise scalability
- Agentforce works more reliably with a single Apex orchestration action
## Customer Intelligence Layer (Data Cloud Simulation)

A dedicated customer intelligence layer is introduced using `Customer_Insight__c`, which simulates Salesforce Data Cloud unified profile behavior.

This layer enriches the support decision before the core case logic is executed.

### Key Attributes
- Segment (VIP / Enterprise / Standard)
- Health Score
- Churn Risk
- Preferred Support Channel

### Enterprise Behavior

- High Churn Risk → Direct escalation and High Priority
- VIP / Enterprise → Priority High and faster routing
- Low Health Score → Faster support path
- Preferred Channel → Included in support context

### Design Principle

Data Cloud is not replacing the support logic.

It acts as an intelligence layer that influences how the system responds before entering the case orchestration flow.
## Key Insight

NexaAssist does not only process a customer request.

It evaluates customer importance, risk and history before deciding the next action.
## Future Data Cloud Layer
Future versions will add:
- Unified customer profile
- Churn risk
- Health score
- Preferred channel
- Semantic duplicate detection