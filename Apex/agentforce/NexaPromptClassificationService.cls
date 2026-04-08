public with sharing class NexaPromptClassificationService {
   public static String classifyCustomerMessage(String customerMessage) {
        if (String.isBlank(customerMessage)) {
            return getFallbackJson('Customer message was blank.');
        }

        try {
            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

            ConnectApi.WrappedValue messageValue = new ConnectApi.WrappedValue();
            messageValue.value = customerMessage;
           // inputParams.put('customerMessage', messageValue);
           inputParams.put('Input:customerMessage',messageValue);

            ConnectApi.EinsteinPromptTemplateGenerationsInput input =
                new ConnectApi.EinsteinPromptTemplateGenerationsInput();

            input.inputParams = inputParams;
            input.isPreview = false;
            input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            input.additionalConfig.applicationName = 'PromptBuilderPreview';

            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                    'Nexa_Support_Classification_Template',
                    input
                );

            if (response != null &&
                response.generations != null &&
                !response.generations.isEmpty() &&
                !String.isBlank(response.generations[0].text)) {

                String rawResponse = response.generations[0].text;
                System.debug('Nexa Prompt Raw Response: ' + rawResponse);
                return rawResponse;
            }

            //return getFallbackJson('Prompt returned no generation text.');
            return getFallbackJson('PROMPT_EMPTY_MARKER_V2');

        } 
        catch (Exception e) {
    System.debug('Nexa Prompt Template Error Type: ' + e.getTypeName());
    System.debug('Nexa Prompt Template Error Message: ' + e.getMessage());
    System.debug('Nexa Prompt Template Stack: ' + e.getStackTraceString());
    return getFallbackJson('PROMPT_ERROR_MARKER_V2__' + e.getMessage());
}
        //catch (Exception e) {
          //  System.debug('Nexa Prompt Template Error: ' + e.getMessage());
            //return getFallbackJson('Prompt invocation failed.');
            //return getFallbackJson('PROMPT_ERROR_MARKER_V2'+e.getMessage());
       // }
    }

    private static String getFallbackJson(String summaryMessage) {
        return '{"intent":"new_support_request","category":"General Inquiry","issueNature":null,"wantsHumanSupport":false,"summary":"' +
            escapeJson(summaryMessage) + '"}';
    }

    private static String escapeJson(String value) {
        if (value == null) {
            return '';
        }

        String escaped = value;
        escaped = escaped.replace('\\', '\\\\');
        escaped = escaped.replace('"', '\\"');
        escaped = escaped.replace('\n', '\\n');
        escaped = escaped.replace('\r', '\\r');
        escaped = escaped.replace('\t', '\\t');
        return escaped;
    }
}