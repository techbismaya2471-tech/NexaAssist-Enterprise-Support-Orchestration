public with sharing class AgentApiService {
    public class ConfigData {
        public String clientId;
        public String clientSecret;
        public String tokenEndpoint;
        public String instanceEndpoint;
        public String agentId;
    }

    public class SessionResponse {
        public String sessionId;
        public String messageUrl;
    }

    public static ConfigData getConfig() {
        Agent_Api_Config__mdt config = Agent_Api_Config__mdt.getInstance('Default_Config');

        ConfigData data = new ConfigData();
        data.clientId = config.Client_Id__c;
        data.clientSecret = config.Client_Secret__c;
        data.tokenEndpoint = config.Token_Endpoint__c;
        data.instanceEndpoint = config.Instance_Endpoint__c;
        data.agentId = config.Agent_Id__c;

        return data;
    }

    public static String getAccessToken() {
        ConfigData config = getConfig();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.tokenEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body =
            'grant_type=client_credentials' +
            '&client_id=' + EncodingUtil.urlEncode(config.clientId, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(config.clientSecret, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Token Response: ' + res.getBody());

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('Failed to get token: ' + res.getBody());
        }

        Map<String, Object> tokenMap =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        return (String) tokenMap.get('access_token');
    }

    public static SessionResponse createSession(String accessToken) {
        ConfigData config = getConfig();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'https://api.salesforce.com/einstein/ai-agent/v1/agents/' +
            config.agentId +
            '/sessions'
        );
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('externalSessionKey', 'session-' + Datetime.now().getTime());

        Map<String, Object> instanceConfig = new Map<String, Object>();
        instanceConfig.put('endpoint', config.instanceEndpoint);

        bodyMap.put('instanceConfig', instanceConfig);
        bodyMap.put('bypassUser', true);

        req.setBody(JSON.serialize(bodyMap));

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Create Session Response: ' + res.getBody());

        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            throw new AuraHandledException('Failed to create session: ' + res.getBody());
        }

        Map<String, Object> responseMap =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        SessionResponse session = new SessionResponse();
        session.sessionId = (String) responseMap.get('sessionId');

        Map<String, Object> links =
            (Map<String, Object>) responseMap.get('_links');

        Map<String, Object> messages =
            (Map<String, Object>) links.get('messages');

        session.messageUrl = (String) messages.get('href');

        return session;
    }

    public static String sendMessage(String accessToken, String sessionId, String messageText, Integer sequenceId) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(
        'https://api.salesforce.com/einstein/ai-agent/v1/sessions/' +
        sessionId +
        '/messages'
    );
    req.setMethod('POST');
    req.setHeader('Authorization', 'Bearer ' + accessToken);
    req.setHeader('Content-Type', 'application/json');

    Map<String, Object> messageMap = new Map<String, Object>();
    messageMap.put('sequenceId', sequenceId);
    messageMap.put('type', 'Text');
    messageMap.put('text', messageText);

    Map<String, Object> bodyMap = new Map<String, Object>();
    bodyMap.put('message', messageMap);

    req.setBody(JSON.serialize(bodyMap));

    Http http = new Http();
    HttpResponse res = http.send(req);

    System.debug('Send Message Response: ' + res.getBody());

    if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
        throw new AuraHandledException('Failed to send message: ' + res.getBody());
    }

    Map<String, Object> responseMap =
        (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

    List<Object> messages = (List<Object>) responseMap.get('messages');

    if (messages != null && !messages.isEmpty()) {
        Map<String, Object> firstMessage = (Map<String, Object>) messages[0];
        return (String) firstMessage.get('message');
    }

    return 'No response returned from agent.';
}


}