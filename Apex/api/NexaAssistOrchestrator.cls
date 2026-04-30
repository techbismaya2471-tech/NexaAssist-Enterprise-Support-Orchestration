public with sharing class NexaAssistOrchestrator {
    public static NexaAssistResponse process(NexaAssistRequest req) {
        NexaAssistResponse res = new NexaAssistResponse();

        try {
            String token = AgentApiService.getAccessToken();

            String activeSessionId;

            if (String.isNotBlank(req.sessionId)) {
                activeSessionId = req.sessionId;
            } else {
                AgentApiService.SessionResponse session =
                    AgentApiService.createSession(token);
                activeSessionId = session.sessionId;
            }

            // lastCategory ko message ke saath append karo
            String messageToSend = req.message;
            if (String.isNotBlank(req.lastCategory)) {
                messageToSend = req.message + ' ||lastCategory:' + req.lastCategory + '||';
            }

            String agentReply = AgentApiService.sendMessage(
                token,
                activeSessionId,
                messageToSend,
                1
            );

            res.success   = true;
            res.message   = agentReply;
            res.sessionId = activeSessionId;

        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }

        return res;
    }
}