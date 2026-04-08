global with sharing class NexaAssistResponse {
   public Boolean success;
    public String category;
    public String message;
    public Boolean escalated;
    public String caseNumber;
    public String sessionId;
    public List<String> suggestedActions;
    public Map<String, Object> insights;

    public NexaAssistResponse() {
        this.success = true;
        this.escalated = false;
        this.suggestedActions = new List<String>();
        this.insights = new Map<String, Object>();
    }
}