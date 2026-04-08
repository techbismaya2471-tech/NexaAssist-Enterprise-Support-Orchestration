# End-to-End Business Flow

1. Customer sends support request
2. Agent asks for email if not already known
3. Contact is searched by email
4. If no contact exists → no case is created
5. Request is classified into category:
   - Billing
   - Login
   - Subscription
   - Technical
   - Planning
   - Service
   - General Inquiry
6. Existing open cases are checked

### Same Category + Open Case
- First repeat → existing case escalated
- Priority becomes High
- Escalated__c = true
- Human support routing starts

### Same Category + Already Escalated
- No new case is created
- Customer is informed that support is already in progress

### Different Category
- New case is created

### Multiple Open Cases
- If customer asks for human support without specifying category:
  - System asks which issue they want help with
- If category is known:
  - Existing case is escalated or new case is created and escalated

### Technical Issues
Technical issues are additionally classified into:
- Physical
- Remote
- Unknown