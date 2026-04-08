# API Integration Layer

## Overview

NexaAssist exposes an external Apex REST endpoint so that third-party systems such as a website, portal, or external application can send customer support requests into Salesforce.

This makes the project more than an internal Salesforce chatbot. It becomes an API-driven enterprise support platform.

## Main Components

### 1. NexaAssistApiController
Acts as the external REST entry point.

Responsibilities:
- receives the incoming HTTP POST request
- reads raw JSON body
- deserializes request into `NexaAssistRequest`
- passes control to `NexaAssistOrchestrator`
- returns final JSON response

### 2. NexaAssistOrchestrator
Acts as the orchestration layer between the external request and Agentforce runtime.

Responsibilities:
- receives structured request object
- requests OAuth access token
- creates Agentforce session
- sends customer message to Agentforce
- returns final response to API caller

### 3. AgentApiService
Handles the actual communication with Salesforce Agent APIs.

Responsibilities:
- reads configuration from Custom Metadata
- gets OAuth access token using client credentials
- creates a conversation session
- sends customer message to Agentforce
- parses the first response message

## Request Wrapper

`NexaAssistRequest` supports fields like:
- sessionId
- customerEmail
- customerExternalId
- message
- source
- correlationId

This allows the API to evolve into a future multi-channel support system.

## Response Wrapper

`NexaAssistResponse` supports fields like:
- success
- category
- message
- escalated
- caseNumber
- sessionId
- suggestedActions
- insights

This makes the design future-ready for analytics, recommendations, and customer intelligence.

## Security and Configuration

Sensitive integration values are not hardcoded.

They are stored in Salesforce Custom Metadata (`Agent_Api_Config__mdt`), including:
- Client Id
- Client Secret
- Token Endpoint
- Agent Id
- Instance Endpoint

## Enterprise Value

This design provides:
- reusable external integration
- cleaner separation of layers
- secure config-driven architecture
- easier deployment across environments
- future support for website, mobile app, portal, or multi-channel integrations

## Interview Positioning

A strong way to explain this layer:

> I exposed a custom Apex REST API that allows external systems to invoke the support platform. The controller delegates to an orchestration layer, which securely authenticates with Salesforce Agent APIs, creates a session, sends the customer message to Agentforce, and returns the final response as JSON.