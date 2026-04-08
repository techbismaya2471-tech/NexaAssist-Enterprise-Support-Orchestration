
@RestResource(urlMapping='/nexaassist/v1/chat')
global with sharing class NexaAssistApiController {
      @HttpPost
    global static void handleChat() {
        NexaAssistResponse res = new NexaAssistResponse();

        try {
            String requestBody = RestContext.request.requestBody.toString();
            NexaAssistRequest req =
                (NexaAssistRequest) JSON.deserialize(requestBody, NexaAssistRequest.class);

            res = NexaAssistOrchestrator.process(req);

        } catch (Exception e) {
            res.success = false;
            res.message = 'Something went wrong. Please try again later.';
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
    }
    
}