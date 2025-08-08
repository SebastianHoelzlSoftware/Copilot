# Core Service Workflows

## Dev Request Service Workflow

For Data Models see: [DATA_MODELS](../docs/DATA_MODELS.md)

### 1. Customer Submits a Project Brief

*   The customer fills out a form with the required information about their project (title, summary, and any initial requirements).
*   This form submission triggers a POST request to the /api/project_briefs endpoint.
*   The BriefController receives this request.

### 2. Processing the Brief (Initial Stage)

*   The BriefController calls the Briefs.create_project_brief(params) function to create a new ProjectBrief.
*   The ProjectBrief data (title, summary, customer_id, etc.) is saved to the database.
*   (If configured) The AI assistant could then analyze the brief (see stories COP-97, COP-98, COP-100, and COP-101):
    *   The AI suggests relevant software building blocks.
    *   The AI asks clarifying questions to gather more precise requirements.
    *   The AI identifies potential ambiguities or missing information.
*   This analysis would likely trigger a POST request to your Private Gemini API, which would be handled asynchronously. The results could then be stored in the project_brief or related tables.

### 3. Developer Review and Action

*   The developer receives a notification about the new project brief (COP-89).
*   The developer reviews the brief and all gathered information.
*   The developer decides to accept or decline the project (COP-15).
*   The developer's decision triggers a PUT request to /api/project_briefs/:id/status.
*   The BriefController updates the status field in the ProjectBrief record (accepted or declined).
*   The BriefController could then notify the customer about the developer's decision.

### 4. Subsequent Actions (Post-Acceptance)

*   If the project is accepted, the customer can then access the project space (COP-9).
*   The customer and developer can communicate directly within the platform (COP-90).
*   The developer can manage requirements, upload files, etc.
*   The customer receives status updates (COP-89).
*   The developer generates a formal project proposal and detailed cost estimate (COP-92).

### 5. Notifications:

*   Throughout the whole process, you'll use a PubSub system (as you mentioned in COP-87) to send notifications.
*   Whenever a key event happens (new brief, status update, new message), you'll publish a message to the appropriate topic in PubSub.
*   The Notification Service (a separate application or GenServer) subscribes to these topics and sends out notifications via email or in-app messages.

### 6. Data Flow Summary:

1.  Customer submits brief -> BriefController -> Briefs context -> Database
2.  AI Assistant analyzes brief (asynchronously) -> updates database
3.  Developer reviews brief -> BriefController -> Briefs context -> Database
4.  Status changes trigger PubSub events -> Notification Service -> Customer/Developer notifications