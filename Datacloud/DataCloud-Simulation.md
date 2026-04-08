# Data Cloud Simulation Strategy

## Why Data Cloud Was Added

NexaAssist was intentionally designed so that it can later evolve from a normal support bot into an enterprise customer-intelligence platform.

The current project already simulates Data Cloud behavior using custom Salesforce objects and Apex services.

This creates a strong foundation for future integration with Salesforce Data Cloud.

---

## Current Simulated Customer Profile

The project currently stores customer intelligence inside a custom object such as:

- Customer_Insight__c

The object is linked to the Contact and stores business-level customer insight values.

Example fields:
- Customer Segment
- Health Score
- Churn Risk
- Preferred Support Channel
- Adoption Score
- Lifetime Value
- VIP Customer Flag

---

## Current Runtime Usage

Before support logic runs, the system loads customer insight data through `CustomerInsightService`.

This insight influences:
- escalation priority
- messaging tone
- whether human support should be recommended faster
- support urgency
- possible future routing decisions

Example:

- A VIP customer with high churn risk may be escalated immediately
- A customer with low health score may receive proactive human support
- A customer who prefers phone support may later be routed differently

---

## Future Data Cloud Integration

In a production version, the custom object can be replaced with Salesforce Data Cloud unified profiles.

Future Data Cloud sources may include:
- CRM account history
- product usage
- billing history
- support case history
- website activity
- email engagement
- external product telemetry

Identity Resolution can merge all these sources into one unified customer profile.

---

## Future Enterprise Capabilities

With real Data Cloud integration, NexaAssist could support:

- dynamic customer segmentation
- churn-risk-based escalation
- AI-generated next best action
- proactive support recommendations
- personalized support experience
- executive dashboarding
- predictive customer health scoring

---

## Why This Is Important

This makes NexaAssist more than a chatbot.

It becomes an enterprise support orchestration platform that combines:
- Agentforce
- Apex orchestration
- API integration
- Customer intelligence
- Future Data Cloud readiness

---

## Interview Positioning

> Although the current implementation uses a simulated customer insight object, the architecture was intentionally designed to be Data Cloud-ready. The same service layer can later consume unified customer profiles from Salesforce Data Cloud without changing the overall orchestration design.