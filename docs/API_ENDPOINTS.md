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

#### `GET /api/me`

Returns the full profile for the currently authenticated user.

**Example Response (`200 OK`)**
```json
{
  "id": "usr_12345",
  "email": "test@example.com",
  "name": "Test User",
  "roles": ["customer"],
  "inserted_at": "2023-10-27T10:00:00Z",
  "updated_at": "2023-10-27T10:00:00Z"
}
```

#### `PUT /api/me`

Updates the user's profile. Only the provided fields will be updated.

**Example Request Body**
```json
{
  "name": "A New Name"
}
```

---

## User Administration

These endpoints are for privileged administrative actions on user accounts.

**Access**: Developers only.

| Method | Path                  | Description                   |
| :----- | :-------------------- | :---------------------------- |
| `PUT`  | `/api/users/:id/role` | Update a specific user's roles. |

#### `PUT /api/users/:id/role`

Updates the roles for a specific user. This will replace the existing roles.

**Example Request Body**
```json
{
  "roles": ["developer"]
}
```

## Registration

**Endpoint:** `/api/register`

**Access:** Public (no authentication required)

| Method | Path          | Description                               |
| :----- | :------------ | :---------------------------------------- |
| `POST` | `/api/register` | Registers a new user and creates a customer account. |

#### `POST /api/register`

Registers a new user and creates an associated customer account.

**Example Request Body**
```json
{
  "registration": {
    "email": "newuser@example.com",
    "password": "securepassword",
    "name": "New User Name",
    "customer_name": "New User's Company"
  }
}
```

**Example Response (`201 Created` or `200 OK`)**
```json
{
  "data": {
    "id": "usr_abcdef",
    "customer_id": "cust_123456"
  }
}
```

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

#### `POST /api/customers`

Creates a new customer account.

**Example Request Body**
```json
{
  "name": "Big Corp",
  "contact_email": "billing@bigcorp.com"
}
```

**Example Response (`201 Created`)**
```json
{
  "id": "cust_abc789",
  "name": "Big Corp",
  "contact_email": "billing@bigcorp.com",
  "inserted_at": "2023-10-27T11:00:00Z",
  "updated_at": "2023-10-27T11:00:00Z"
}
```

#### `GET /api/customers/:id`

Returns a single customer's details. The response format is the same as the one for `POST /api/customers`.

#### `PUT /api/customers/:id`

Updates a customer's details. Only the provided fields will be updated.

**Example Request Body**
```json
{
  "name": "Big Corp Ltd."
}
```
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

#### `POST /api/cost_estimates`

Creates a new cost estimate.

**Example Request Body**
```json
{
  "customer_id": "cust_abc789",
  "title": "Project X Estimate",
  "description": "Initial cost estimate for Project X.",
  "amount": 15000,
  "currency": "USD"
}
```

**Example Response (`201 Created`)**

The response will be the newly created cost estimate object.

#### `PUT /api/cost_estimates/:id`

Updates a cost estimate.

**Example Request Body**
```json
{
  "title": "Project X Estimate (Revised)",
  "amount": 17500,
  "status": "sent"
}
```

### Project Briefs (`/api/briefs`)

*Follows a similar authorization pattern to Cost Estimates.*

### Contacts (`/api/contacts`)

*Follows a similar authorization pattern to Cost Estimates.*

### AI Analyses (`/api/ai_analyses`)

*Follows a similar authorization pattern to Cost Estimates.*
