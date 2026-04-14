public with sharing class NexaSupportRequestAction {
    public class Request {
        @InvocableVariable(required=true)
        public String userMessage;

        @InvocableVariable
        public String customerEmail;
    }

    public class Response {
        @InvocableVariable
        public String responseMessage;

        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public Boolean waitingForEmail;
    }

    @InvocableMethod(label='Handle Nexa Support Request')
    public static List<Response> handle(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            res.success = false;
            res.waitingForEmail = false;

            if (String.isBlank(req.customerEmail)) {

                Interaction_Log__c pendingLog = new Interaction_Log__c();
                pendingLog.Query_Text__c = req.userMessage;
                pendingLog.Response_Summary__c = 'Awaiting customer email before support processing.';
                pendingLog.Source_Channel__c = NexaSupportConfig.SOURCE_CHANNEL_AGENTFORCE;
                pendingLog.Pending_Follow_Up_status__c = NexaSupportConfig.FOLLOW_UP_STATUS_PENDING;
                pendingLog.Pending_Follow_Up_Type__c = NexaSupportConfig.FOLLOW_UP_TYPE_CLARIFICATION;
                pendingLog.Correlation_Id__c = String.valueOf(Crypto.getRandomLong());
                //pendingLog.Channel_Type__c = 'Web';
                pendingLog.Channel_Type__c = deriveChannelType('agentforce');
                pendingLog.Identity_Resolution_Status__c = 'Unknown';
                pendingLog.Interaction_Timestamp__c = DateTime.now();
                pendingLog.Resolution_Status__c = 'Unresolved';
                pendingLog.Customer_Sentiment__c = 'Neutral';

                insert pendingLog;

                res.waitingForEmail = true;
                res.responseMessage = NexaSupportConfig.MSG_PROVIDE_EMAIL;
                results.add(res);
                continue;
            }

            List<Contact> contacts = [
                SELECT Id, Name, Email, AccountId
                FROM Contact
                WHERE Email = :req.customerEmail
                LIMIT 1
            ];

            if (contacts.isEmpty()) {
                res.responseMessage = NexaSupportConfig.MSG_CONTACT_NOT_FOUND;
                results.add(res);
                continue;
            }
            CustomerInsightService.InsightResult insightResult = 
            CustomerInsightService.fetchInsight(contacts[0].Id);

            List<Interaction_Log__c> pendingLogs = [
                SELECT Id, Query_Text__c, Pending_Follow_Up_status__c, Pending_Follow_Up_Type__c
                FROM Interaction_Log__c
                WHERE Pending_Follow_Up_status__c = :NexaSupportConfig.FOLLOW_UP_STATUS_PENDING
                  AND Pending_Follow_Up_Type__c = :NexaSupportConfig.FOLLOW_UP_TYPE_CLARIFICATION
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            String issueToProcess = req.userMessage;

            if (!pendingLogs.isEmpty() && !String.isBlank(pendingLogs[0].Query_Text__c)) {
            issueToProcess = pendingLogs[0].Query_Text__c;

            pendingLogs[0].Contact__c = contacts[0].Id;
            pendingLogs[0].Identity_Resolution_Status__c = 'Matched Existing Customer';
            pendingLogs[0].Unified_Customer_Key__c =buildUnifiedCustomerKey(contacts[0]);
            if (String.isNotBlank(insightResult.unifiedCustomerId)) {
                pendingLogs[0].Unified_Customer_Key__c = insightResult.unifiedCustomerId;
            }
            pendingLogs[0].Channel_Type__c = deriveChannelType('agentforce');
            pendingLogs[0].Pending_Follow_Up_Type__c =NexaSupportConfig.FOLLOW_UP_TYPE_CLARIFICATION;
            
            pendingLogs[0].Pending_Follow_Up_status__c = NexaSupportConfig.FOLLOW_UP_STATUS_COMPLETED;
            pendingLogs[0].Response_Summary__c = 'Customer email verified and original issue recovered for support processing.';
            update pendingLogs[0];
                }
                else {
                    Interaction_Log__c completedLog = new Interaction_Log__c();
                    completedLog.Contact__c = contacts[0].Id;
                    completedLog.Query_Text__c = req.userMessage;
                    completedLog.Source_Channel__c = NexaSupportConfig.SOURCE_CHANNEL_AGENTFORCE;
                    completedLog.Channel_Type__c = deriveChannelType('agentforce');
                    completedLog.Identity_Resolution_Status__c = 'Matched Existing Customer';
                    completedLog.Unified_Customer_Key__c = buildUnifiedCustomerKey(contacts[0]);
                    if (insightResult != null && String.isNotBlank(insightResult.unifiedCustomerId)) {
                        completedLog.Unified_Customer_Key__c = insightResult.unifiedCustomerId;
                        }
                    completedLog.Pending_Follow_Up_Type__c = NexaSupportConfig.FOLLOW_UP_TYPE_CLARIFICATION;
                    completedLog.Pending_Follow_Up_Status__c = NexaSupportConfig.FOLLOW_UP_STATUS_COMPLETED;
                    completedLog.Response_Summary__c = 'Customer email verified and issue processed through support flow.';
                    completedLog.Interaction_Timestamp__c = DateTime.now();
                    completedLog.Resolution_Status__c = 'Unresolved';
                    completedLog.Customer_Sentiment__c = 'Neutral';
                    insert completedLog;
                }

            String rawClassificationResponse =
                NexaPromptClassificationService.classifyCustomerMessage(issueToProcess);

            System.debug('Raw Prompt JSON: ' + rawClassificationResponse);

            NexaClassificationParserV2.Response parsed =
                NexaClassificationParserV2.parseSingle(rawClassificationResponse);

            String detectedCategory = parsed != null ? parsed.category : null;
            Boolean wantsHumanSupport = parsed != null ? parsed.wantsHumanSupport : null;
            String issueNature = parsed != null ? parsed.issueNature : null;
            String classificationSummary = parsed != null ? parsed.summary : null;
            String detectedIntent = parsed != null ? parsed.intent : null;

            System.debug('ACTION_RAW_JSON = ' + rawClassificationResponse);
            System.debug('ACTION_PARSED_CATEGORY = ' + detectedCategory);
            System.debug('ACTION_PARSED_INTENT = ' + detectedIntent);
            System.debug('ACTION_PARSED_ISSUE_NATURE = ' + issueNature);
            System.debug('ACTION_PARSED_WANTS_HUMAN = ' + wantsHumanSupport);
            System.debug('ACTION_PARSED_SUMMARY = ' + classificationSummary);

            /*  if (String.isBlank(detectedCategory)) {
                detectedCategory = 'General INquiry';
            }

            if (wantsHumanSupport == null) {
                wantsHumanSupport = false;
            }*/

                if (String.isBlank(detectedCategory)) {
                    res.success = false;
                    res.responseMessage = NexaSupportConfig.MSG_UNSUPPORTED_REQUEST;
                    results.add(res);
                    continue;
                }

                Set<String> supportedCategories = new Set<String>{
                    'Login',
                    'Billing',
                    'Technical',
                    'General Inquiry'
                };

                if (!supportedCategories.contains(detectedCategory)) {
                    res.success = false;
                    res.responseMessage = NexaSupportConfig.MSG_UNSUPPORTED_REQUEST;
                    results.add(res);
                    continue;
                }
                if (wantsHumanSupport == null) {
                wantsHumanSupport = false;
            }


            String finalProcessingMessage = processSupportCase(
                contacts[0],
                issueToProcess,
                detectedCategory,
                wantsHumanSupport,
                issueNature,
                 insightResult
            );

            res.success = true;
            //res.responseMessage = finalProcessingMessage;
            //res.responseMessage = finalProcessingMessage + ' | DEBUG category=' + detectedCategory;
            res.responseMessage = finalProcessingMessage
    + ' | DEBUG raw=' + rawClassificationResponse
    + ' | category=' + detectedCategory;
            results.add(res);
        }

        return results;
    }

    private static String processSupportCase(
        Contact matchedContact,
        String issueToProcess,
        String detectedCategory,
        Boolean wantsHumanSupport,
        String issueNature,
        CustomerInsightService.InsightResult insightResult
    ) {
       // CustomerInsightService.InsightResult insightResult =
        //CustomerInsightService.fetchInsight(matchedContact.Id);
        // CustomerInsightService.InsightResult insightResult=
        // CustomerInsightService.fetchInsight(matchedContact.Id);

        Boolean forceEscalationFromInsight = insightResult.forceEscalation;
        Boolean forceHighPriorityFromInsight = insightResult.forceHighPriority;
        Boolean fasterSupportPathFromInsight = insightResult.fasterSupportPath;
        String insightNote = insightResult.internalInsightNote;

        System.debug('INSIGHT hasInsight=' + insightResult.hasInsight
    + ', segment=' + insightResult.segment
    + ', healthScore=' + insightResult.healthScore
    + ', churnRisk=' + insightResult.churnRisk
    + ', preferredChannel=' + insightResult.preferredChannel
    + ', adoptionScore=' + insightResult.adoptionScore
    + ', lastProductUsageDate=' + insightResult.lastProductUsageDate
    + ', unifiedCustomerId=' + insightResult.unifiedCustomerId);
        
        
        Group humanSupportQueue = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND DeveloperName = :NexaSupportConfig.HUMAN_SUPPORT_QUEUE_DEV_NAME
            LIMIT 1
        ];
        Integer totalOpenCases = [
            SELECT COUNT()
            FROM Case
            WHERE ContactId = :matchedContact.Id
              AND Status != :NexaSupportConfig.CASE_STATUS_CLOSED
        ];

        List<Case> existingCases = [
            SELECT Id, CaseNumber, Status, Priority, Escalated__c, Issue_Category__c
            FROM Case
            WHERE ContactId = :matchedContact.Id
              AND Status != :NexaSupportConfig.CASE_STATUS_CLOSED
              AND Issue_Category__c = :detectedCategory
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!existingCases.isEmpty()) {
            Case existingCase = existingCases[0];

            if (existingCase.Escalated__c == true) {
                return NexaSupportConfig.MSG_ALREADY_ESCALATED;
            }

            existingCase.Priority = NexaSupportConfig.PRIORITY_HIGH;
            existingCase.Escalated__c = true;
            existingCase.OwnerId=humanSupportQueue.Id;
            update existingCase;

            return 'Your existing case ' + existingCase.CaseNumber +
                ' has been escalated to our human support team with high priority.';
        }

        Boolean requiresImmediateEscalation = false;

        if (totalOpenCases >= 2) {
            requiresImmediateEscalation = true;
        }
        if (forceEscalationFromInsight) {
            requiresImmediateEscalation = true;
        }
        if (fasterSupportPathFromInsight) {
            requiresImmediateEscalation = true;
        }

        if (detectedCategory == NexaSupportConfig.CATEGORY_TECHNICAL) {
            if (issueNature == NexaSupportConfig.ISSUE_NATURE_PHYSICAL) {
                requiresImmediateEscalation = true;
            }

            if (wantsHumanSupport == true) {
                requiresImmediateEscalation = true;
            }
        }

        Case newCase = new Case();
        newCase.ContactId = matchedContact.Id;
        newCase.AccountId = matchedContact.AccountId;
        newCase.Subject = 'NexaAssist Support - ' + detectedCategory;
        newCase.Description = issueToProcess;
    if (String.isNotBlank(insightNote)) {
             newCase.Description = (newCase.Description == null ? '' : newCase.Description + '\n\n')
          + 'Customer Insight: ' + insightNote;
       }
        newCase.Status = NexaSupportConfig.CASE_STATUS_NEW;
        /*newCase.Priority = requiresImmediateEscalation
            ? NexaSupportConfig.PRIORITY_HIGH
            : NexaSupportConfig.PRIORITY_MEDIUM;*/

          newCase.Priority = (requiresImmediateEscalation || forceHighPriorityFromInsight)
            ? NexaSupportConfig.PRIORITY_HIGH
            : NexaSupportConfig.PRIORITY_MEDIUM;
            
        newCase.Issue_Category__c = detectedCategory;
        System.debug('CASE_CATEGORY_BEFORE_INSERT = ' + newCase.Issue_Category__c);

        insert newCase;
        newCase=[ Select Id,CaseNumber from Case where Id=:newCase.Id];

        if (requiresImmediateEscalation) {
            newCase.Escalated__c = true;
            newCase.Priority = NexaSupportConfig.PRIORITY_HIGH;
            newCase.OwnerId=humanSupportQueue.Id;
            update newCase;

            return 'A new support case ' + newCase.CaseNumber +
                ' has been created and escalated to our human support team with high priority.';
        }

        return 'A new support case ' + newCase.CaseNumber +
            ' has been created successfully. Our team will continue working on your request.';
    }
    private static String deriveChannelType(String source) {
    if (String.isBlank(source)) {
        return 'Web';
    }

    String normalizedSource = source.trim().toLowerCase();

    if (normalizedSource == 'web' ||
        normalizedSource == 'chat' ||
        normalizedSource == 'agentforce' ||
        normalizedSource == 'messaging') {
        return 'Web';
    }

    if (normalizedSource == 'email') {
        return 'Email';
    }

    if (normalizedSource == 'api' ||
        normalizedSource == 'portal' ||
        normalizedSource == 'integration') {
        return 'API';
    }

    if (normalizedSource == 'voice' ||
        normalizedSource == 'call') {
        return 'Voice';
    }

    return 'Web';
}
/*private static String deriveChannelType() {
    return 'Web';
}*/
private static String buildUnifiedCustomerKey(Contact c) {
    if (c == null) {
        return null;
    }

    if (c.AccountId != null) {
        return 'ACC-' + c.AccountId + '_CON-' + c.Id;
    }

    return 'CON-' + c.Id;
}
}