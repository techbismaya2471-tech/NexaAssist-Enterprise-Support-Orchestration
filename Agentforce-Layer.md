# Agentforce Runtime Layer

## Overview

NexaAssist uses Agentforce as the conversation intelligence layer.

Agentforce is responsible for understanding the customer message, detecting intent, classifying support category, and identifying whether the customer is asking for human support.

The final business decision is then applied by Apex orchestration logic.

## Key Components

### 1. Prompt Template
`Nexa Support Classification Template`

Purpose:
- semantically classify the customer message
- identify issue category
- identify human support request
- provide structured JSON output

### 2. NexaPromptClassificationService
Calls the prompt template and retrieves classification output.

### 3. NexaClassificationParserV2
Parses the prompt output into structured Apex-friendly fields.

Main extracted values:
- category
- summary
- intent
- wantsHumanSupport
- issueNature

### 4. NexaSupportRequestAction
This is the main runtime action used by Agentforce.

Purpose:
- validate customer email
- resolve Contact
- call classification layer
- check customer insight
- execute support-case business rules
- create or escalate cases
- return final response message

### 5. CustomerInsightService
Provides customer intelligence enrichment after Contact resolution.

Purpose:
- fetch `Customer_Insight__c`
- simulate Data Cloud profile behavior
- apply escalation/priority influence before case logic runs

### 6. NexaSupportConfig
Stores reusable labels, constants, category names, and messaging values.

## Runtime Sequence

1. Customer sends support request
2. Agentforce requests email if needed
3. Contact is resolved from email
4. Prompt template classifies the issue
5. Parser extracts structured fields
6. Customer insight layer is queried
7. Apex support action applies enterprise support logic
8. Case is created / escalated / reused
9. Human support routing happens if required

## Why This Layer Matters

This design separates:
- AI understanding
- structured parsing
- enterprise business logic

That makes the system more reliable than mixing all logic in prompts or in Flow only.

## Enterprise Value

The Agentforce layer enables:
- semantic classification instead of keyword matching
- intelligent customer conversation handling
- reusable conversation front-end
- cleaner support automation flow
- easier future upgrade to RAG or advanced AI behaviors

## Interview Positioning

A strong way to explain this layer:

> Agentforce is used as the conversation intelligence layer, while Apex remains the deterministic decision engine. This separation allows the system to understand customer language semantically but still enforce enterprise-grade support rules in a reliable and maintainable way.