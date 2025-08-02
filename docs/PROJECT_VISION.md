# Project Vision: Business Copilot API

## The Problem
Small Software companies, especially those with just one single developer (who might also be the business operator) often struggle with the project management overhead. Especially Requirements- and Change Request Management are affected by this. Too little care in the Requirements Gathering phase of the project leads to more Change Requests later on. The latter usually leads to big delays in development. Customers can't rely on cost and time estimates anymore and there's overall frustration. Furthermore those small businesses due to the lack of menpower are the most prone to chaotic business management. They often fail to deliver on their promises, guiding companies away to the often more expensive but bigger competitors.

## The Solution
The Business Copilot is a tool that assists small software companies with their project management. It can be used to automate the process. It emphasizes the initial phases of requirement gathering and refining, as well as the change requests management. It also acts as an interface between commonly used services like (in my case, which will be the first one tackled by Copilot API) Jira, Slack, Google Calendar, Bugtracker and more. @TODO: refine this list

## The Architecture
The Copilot Software shall be composed of the following services:

1. Dev Request Service: This will be responsible for the initial phase. An unstructured request for the development of his app will be submitted to the service. The service will perform an AI analysis on the request and generate a structured cost estimate. It will help the customer to add custom software building blocks to his request so that he can get a better first cost estimate. With the help of AI the developer/business-operator then gets a refined version of this request. Based on this he can decide more accurately whether to accept or decline the project and he can provide an even  more robust final cost-estimate to the customer. 

2. Requirements Service: This service will handle the detailed requirements gathering and refining. It will give the customer the possibility to submit well structured (with the help of AI) User Stories. Those stories will be reviewed by the developer/business-operator and a final version of the requirements will be agreed on. The service should always emphasize the urgency of getting this initial set of requirements as good as possible. There can't be perfection but the better it is, the less change requests will follow and the project's cost and time estimates can be fulfilled. There will be an interface to Jira to add the final user stories to it.

3. Change Request Service: This service will handle the change requests that come in after the requirements gathering phase was completed and the project has started. They might be refined in accordance with the customer or even be declined. They might change cost and time estimates which the service will inform the customer about. They will also use the Jira interface and insert the final change requests to it.

4. Conversation Service: This will implement the slack API so that the developer can conveniently use slack in combination with Jira to get the message passing with the customer done well.

5. Filespace Service: This will be an online file space where both the customer and the developer and/or business operator can upload files for each other. Maybe there can be git versioning of ther files, too (if there's no better solution available).

6. Appointment Service: Here the customer can book an appointment or online meeting with either the business operator and/or the developer. He will see the available dates for appointments and can choose the one that suits him best. He will get provided with a confirmation for either an real world appointment or a videocall (in the latter case he'll be provided with a google meet link).

7. Work Time Tracker Service: This will track the time spent on the project. It will be used to calculate the cost of the project. It's data will be made available for the Project Insight Service (see below)

8. Project Insights Service: Here the customer will have the opportunity to get insights on the current development state. He shall see Jira summary (maybe even more, let's check out Jira's capabilites here), the actual time that has been worked on the project. Estimated releases and more. @TODO: Make a definitive list of insights worth displaying to the customer

9. Invoice Service: This will create invoices based on the customers data and the work time data from the Work Time Tracker Service. It will interact will the business operator's accounting software @TODO: decide which software this shall be

10. Payment Service: This will provide common payment methods to the customer. It will also interact with the business operator's accounting software. 

11. Documentation Service: This will provide a wiki-style (let's say it will be a confluence page) knowledge base to the customer that he can also share (at least parts of the docs) with it's own users of the project i.e. the customer's customers.

12. Notification Service: This is a helper service getting all the notification work from the other services done. (Probably done via Phoenix PubSub and maybe not worth an extra entry in this list)

13. Bugtracker Service: This will provide an interface (or just a link) to a common bugtracking software handling just the configuration and the entanglement with the project. @TODO: Refine this idea.


## Target Audience

- Small businesses down to one person, who build software for arbitrary customers
- Customer's who want maximum transparency and best possible control of their app project.


## Guiding Principles

- **Modular Monolith First**: The system will be built as a single, well-structured application. Each "service" (e.g., Requirements, Invoicing) will be implemented as a distinct context or module within the Phoenix application. This provides clear separation of concerns without the operational overhead of a full microservices architecture, while allowing for future extraction if needed.
- **API First**: The core of the application is its API. This ensures that the business logic is decoupled from the presentation layer and can be consumed by any number of clients (web, mobile, third-party integrations) in the future.
- **Delegate, Don't Build**: For common, non-core problems like authentication, bug tracking, or accounting, we will delegate to best-in-class external services (e.g., Firebase, Jira, Slack). Our value is in integrating these services intelligently, not rebuilding them.
- **Iterative Delivery**: The project will be built and delivered one service/module at a time, starting with the highest-value component (the "Dev Request Service"). This allows for incremental progress, user feedback, and a faster path to a usable product.
- **Pragmatic AI**: The use of AI will be focused and purposeful, aimed at solving specific, high-impact problems in the project management workflow. We will avoid using AI for its own sake and prioritize solutions that provide tangible value to the user.

