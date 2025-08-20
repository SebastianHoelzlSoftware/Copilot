# Time Tracker Documentation

This document describes the Time Tracker (or Time Manager) service. This will be an Gemini assisted personal time manager.
It will be responsible for dynamically creating calendar entries, track time worked on a specific project. 
It will provide the API for an Android App that will send me push notifications via the Android system of upcoming events.
A Gemini API interface inside the android app will have access to my personal (presumably google) calendar and manage my daily routines via Speech or Chat control.

## Architecture

The Time Manager service will be built as a distinct "context" within the existing Phoenix application, following the "Modular Monolith" principle. This ensures a clear separation of concerns while leveraging the shared infrastructure.

### 1. TimeTracking Context
A new `TimeTracking` context will be created to house all the core logic, schemas, and functions related to time tracking. This will live alongside the existing `Core` context.

### 2. Data Model: `TimeEntry` Schema
The central data structure will be the `TimeEntry` Ecto schema. It will contain the following fields:
- `start_time` (UTC datetime): When the time tracking began.
- `end_time` (UTC datetime, nullable): When the time tracking ended. A `nil` value indicates a timer is currently running.
- `description` (text): A short description of the task performed.
- `user_id` (references `Core.Data.User`): The user who is tracking the time.
- `project_brief_id` (references `Core.Data.ProjectBrief`): The project this time entry is associated with.

### 3. API First: RESTful Endpoints
The primary interface will be a set of RESTful API endpoints, which will be consumed by the future Android app and potentially other clients.

- `POST /api/time/entries`: Creates a new time entry. Can be called with or without an `end_time` to start a timer.
- `GET /api/time/entries`: Lists all time entries. Supports filtering by `user_id`, `project_brief_id`, and date ranges.
- `GET /api/time/entries/:id`: Retrieves a single time entry.
- `PUT /api/time/entries/:id`: Updates a time entry (e.g., to add an `end_time` to a running timer).
- `DELETE /api/time/entries/:id`: Removes a time entry.

### 4. Authorization
We will extend the existing authorization plugs. The rules will be straightforward:
- A user with the `developer` role can create, read, update, and delete **their own** time entries.
- Future roles (e.g., `manager`, `admin`) will be granted wider access to view team or project-wide time entries.

### 5. External Service Integration (Future)
As outlined in the introduction, integration with a calendar service is a core goal.
- A dedicated `TimeTracking.GoogleCalendar` module will be responsible for all interactions with the Google Calendar API.
- This module will be triggered after a `TimeEntry` is created or updated, syncing the entry to the user's calendar.
- The interaction with the Gemini API for natural language control will be handled primarily on the client-side (Android app), which will then call our secure API endpoints.

#### TODO:
- [] Add Details on External Service Integration here