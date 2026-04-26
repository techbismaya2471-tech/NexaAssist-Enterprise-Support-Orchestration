public with sharing class NexaClassificationParserV2 {
     public class Request {
        @InvocableVariable(required=true)
        public String jsonResponse;
    }

    public class Response {
        @InvocableVariable
        public String intent;

        @InvocableVariable
        public String category;

        @InvocableVariable
        public String issueNature;

        @InvocableVariable
        public Boolean wantsHumanSupport;

        @InvocableVariable
        public Boolean isFollowUp;

        @InvocableVariable
        public String summary;
    }

    @InvocableMethod(label='Parse Nexa Classification Response V2')
    public static List<Response> parse(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response r = new Response();

            if (String.isBlank(req.jsonResponse)) {
                results.add(r);
                continue;
            }
         String raw = req.jsonResponse;

        r.intent = extractStringValue(raw, 'intent');
        r.category = extractStringValue(raw, 'category');
        r.issueNature = extractNullableStringValue(raw, 'issueNature');
        r.wantsHumanSupport = extractBooleanValue(raw, 'wantsHumanSupport');
        r.isFollowUp = extractBooleanValue(raw, 'isFollowUp');
        r.summary = extractStringValue(raw, 'summary');

            System.debug('Parser raw = ' + raw);
            System.debug('Parser category = ' + r.category);
            System.debug('Parser isFollowUp = ' + r.isFollowUp);
        results.add(r);
        }

        return results;
    }

    private static String getStringValue(Map<String, Object> payload, String key) {
        if (payload == null || !payload.containsKey(key) || payload.get(key) == null) {
            return null;
        }
        return String.valueOf(payload.get(key)).trim();
    }

    private static Boolean getBooleanValue(Map<String, Object> payload, String key) {
        if (payload == null || !payload.containsKey(key) || payload.get(key) == null) {
            return null;
        }

        Object value = payload.get(key);

        if (value instanceof Boolean) {
            return (Boolean) value;
        }

        String strValue = String.valueOf(value).trim().toLowerCase();
        if (strValue == 'true') return true;
        if (strValue == 'false') return false;

        return null;
    }

    public static Response parseSingle(String jsonResponse) {
        Request req = new Request();
        req.jsonResponse = jsonResponse;

        List<Response> results = parse(new List<Request>{ req });

        if (results == null || results.isEmpty()) {
            return null;
        }

        return results[0];
    }

private static String normalize(String raw) {
    if (String.isBlank(raw)) {
        return '';
    }

    String s = raw.trim();

    s = s.replace('```json', '');
    s = s.replace('```', '');
    s = s.replace('\n', '');
    s = s.replace('\r', '');
    s = s.replace('\\n', '');
    s = s.replace('\\r', '');

    return s;
}

private static String extractStringValue(String raw, String key) {
    String s = normalize(raw);

    String keyToken = '"' + key + '"';
    Integer keyPos = s.indexOf(keyToken);

    if (keyPos == -1) {
        return null;
    }

    Integer colonPos = s.indexOf(':', keyPos);
    if (colonPos == -1) {
        return null;
    }

    Integer firstQuotePos = s.indexOf('"', colonPos + 1);
    if (firstQuotePos == -1) {
        return null;
    }

    Integer secondQuotePos = s.indexOf('"', firstQuotePos + 1);
    if (secondQuotePos == -1) {
        return null;
    }

    return s.substring(firstQuotePos + 1, secondQuotePos).trim();
}

private static String extractNullableStringValue(String raw, String key) {
    String s = normalize(raw);

    String keyToken = '"' + key + '"';
    Integer keyPos = s.indexOf(keyToken);

    if (keyPos == -1) {
        return null;
    }

    Integer colonPos = s.indexOf(':', keyPos);
    if (colonPos == -1) {
        return null;
    }

    String remaining = s.substring(colonPos + 1).trim();

    if (remaining.startsWith('null')) {
        return null;
    }

    return extractStringValue(raw, key);
}

private static Boolean extractBooleanValue(String raw, String key) {
    String s = normalize(raw);

    String keyToken = '"' + key + '"';
    Integer keyPos = s.indexOf(keyToken);

    if (keyPos == -1) {
        return false;
    }

    Integer colonPos = s.indexOf(':', keyPos);
    if (colonPos == -1) {
        return false;
    }

    String remaining = s.substring(colonPos + 1).trim();

    if (remaining.startsWith('true')) {
        return true;
    }

    if (remaining.startsWith('false')) {
        return false;
    }

    return false;
}

}