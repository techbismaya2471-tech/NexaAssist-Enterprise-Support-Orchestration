public with sharing class NexaAssistOrchestrator {
 public static NexaAssistResponse process(NexaAssistRequest req) {
    NexaAssistResponse res = new NexaAssistResponse();

    try {
        String token = AgentApiService.getAccessToken();

        AgentApiService.SessionResponse session =
            AgentApiService.createSession(token);

        String agentReply = AgentApiService.sendMessage(
            token,
            session.sessionId,
            req.message,
            1
        );

        res.success = true;
        res.message = agentReply;
        res.sessionId = session.sessionId;

    } catch (Exception e) {
        res.success = false;
        res.message = e.getMessage();
    }

    return res;
}
}