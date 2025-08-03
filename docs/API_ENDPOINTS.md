# API Endpoint Documentation

This document provides a summary of the available API endpoints, their functions, and the required authorization levels.

## Authentication

All requests to `/api/*` endpoints must be authenticated. In development, this is handled by the `DevAuth` plug which simulates a trusted header from an API Gateway. In production, a real API Gateway (like one configured with Firebase) would be responsible for validating a user's token and injecting this header.

## User Profile (`/api/me`)

These endpoints are for the currently authenticated user to manage their own profile.

**Access**: Any authenticated user.

| Method | Path       | Description                               |
| :----- | :--------- | :---------------------------------------- |
| `GET`  | `/api/me`  | Get the current user's profile.           |
| `PUT`  | `/api/me`  | Update the current user's profile (e.g., name). |
| `DELETE`| `/api/me` | Delete the current user's account.        |

---

## User Administration

These endpoints are for privileged administrative actions on user accounts.

**Access**: Developers only.

| Method | Path                  | Description                   |
| :----- | :-------------------- | :---------------------------- |
| `PUT`  | `/api/users/:id/role` | Update a specific user's roles. |

---

## Customers (`/api/customers`)

These endpoints are for managing customer accounts and all their associated data.

**Access**: Developers only.

| Method | Path                 | Description                                       |
| :----- | :------------------- | :------------------------------------------------ |
| `GET`  | `/api/customers`     | List all customer accounts.                       |
| `POST` | `/api/customers`     | Create a new customer account.                    |
| `GET`  | `/api/customers/:id` | Get a specific customer's details.                |
| `PUT`  | `/api/customers/:id` | Update a specific customer's details.             |
| `DELETE`| `/api/customers/:id` | Delete a customer and all their associated data. |

---

## Other Resources

The following resources use a more granular, controller-level authorization model. The general pattern is that developers have full access, while customers can view their own items but have restricted write access.

### Cost Estimates (`/api/cost_estimates`)

| Method | Path                      | Description                               | Access Level              |
| :----- | :------------------------ | :---------------------------------------- | :------------------------ |
| `GET`  | `/api/cost_estimates`     | List all cost estimates.                  | Developer Only (Inferred) |
| `POST` | `/api/cost_estimates`     | Create a new cost estimate.               | Developer Only (Inferred) |
| `GET`  | `/api/cost_estimates/:id` | Get a specific cost estimate.             | Developer or Owner        |
| `PUT`  | `/api/cost_estimates/:id` | Update a specific cost estimate.          | Developer Only            |
| `DELETE`| `/api/cost_estimates/:id` | Delete a specific cost estimate.          | Developer Only            |

### Project Briefs (`/api/briefs`)

*Follows a similar authorization pattern to Cost Estimates.*

### Contacts (`/api/contacts`)

*Follows a similar authorization pattern to Cost Estimates.*

### AI Analyses (`/api/ai_analyses`)

*Follows a similar authorization pattern to Cost Estimates.*

