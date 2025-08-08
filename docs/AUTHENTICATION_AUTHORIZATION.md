## Authentication and Authorization Flow

This section describes the authentication and authorization pipeline for API requests, detailing the sequence of key plugs, their responsibilities, and the data they make available in the connection (`Plug.Conn`).

### API Pipelines

The `router.ex` defines several pipelines that control access to API endpoints:

*   `:public_api`:
    *   **Purpose**: For endpoints that do not require any authentication or authorization.
    *   **Plugs**: `plug :accepts, ["json"]`
    *   **Example**: The user registration endpoint (`POST /api/register`).

*   `:api`:
    *   **Purpose**: The base API pipeline. It handles initial user information extraction.
    *   **Plugs**:
        *   `plug :accepts, ["json"]`
        *   `plug CopilotWeb.Plugs.DevAuth` (Development only): Mocks authentication by setting the `x-user-info` header. This simulates the behavior of an API Gateway injecting user information after validating a JWT. **Crucially, this plug checks for an `x-dev-auth-override` header in the incoming request. If this header is present, its JSON value (e.g., `{"provider_id":"test-user","email":"test@example.com","roles":["customer"]}`) is used to populate the `x-user-info` header, allowing developers to easily test different user roles and attributes without modifying code. If `x-dev-auth-override` is not provided, a default developer payload is used.**
        *   `plug CopilotWeb.Plugs.UserInfo`: Extracts user information from the `x-user-info` header (whether mocked by `DevAuth` or provided by a real API Gateway). It then attempts to find or create the user in the database and assigns the `current_user` struct to `conn.assigns.current_user`. If the header is missing or invalid, `conn.assigns.current_user` will be `nil`.

*   `:protected`:
    *   **Purpose**: For endpoints that require any authenticated user.
    *   **Plugs**: `plug CopilotWeb.Plugs.EnsureAuthenticated` (must be piped through `:api` first).

*   `:developer_only`:
    *   **Purpose**: For endpoints that require an authenticated user with the "developer" role.
    *   **Plugs**: `plug CopilotWeb.Plugs.EnsureAuthenticated`, `plug CopilotWeb.Plugs.Authorization, "developer"` (must be piped through `:api` first).

*   `:admin_only`:
    *   **Purpose**: For endpoints that require an authenticated user with the "admin" role.
    *   **Plugs**: `plug CopilotWeb.Plugs.EnsureAuthenticated`, `plug CopilotWeb.Plugs.Authorization, "admin"` (must be piped through `:api` first).

### Key Authentication and Authorization Plugs

Here's a detailed look at the responsibilities of the core authentication and authorization plugs:

*   `CopilotWeb.Plugs.DevAuth` (Development Only)
    *   **Responsibility**: Simulates an API Gateway's authentication process by injecting a `x-user-info` header into the connection. This header contains a JSON string with user details (e.g., `provider_id`, `email`, `name`, `roles`).
    *   **Data in `conn`**: Sets the `x-user-info` request header. If `x-dev-auth-override` is present, its value is used; otherwise, a default developer payload is used.

*   `CopilotWeb.Plugs.UserInfo`
    *   **Responsibility**: Reads the `x-user-info` header, decodes the JSON, and uses the `Copilot.Core.Users` context to find or create a user in the database based on the provided information.
    *   **Data in `conn`**: Assigns the fetched or created user struct to `conn.assigns.current_user`. If the header is missing, invalid, or the user cannot be processed, `conn.assigns.current_user` will be `nil`.

*   `CopilotWeb.Plugs.EnsureAuthenticated`
    *   **Responsibility**: Verifies that a user has been successfully authenticated. It checks if `conn.assigns.current_user` is present (i.e., not `nil`).
    *   **Data in `conn`**: If `current_user` is `nil`, it halts the connection and sends a `401 Unauthorized` response. Otherwise, it passes the `conn` through unchanged.

*   `CopilotWeb.Plugs.Authorization`
    *   **Responsibility**: Enforces role-based access control. It expects `EnsureAuthenticated` to have run prior to it, ensuring `conn.assigns.current_user` is available. It checks if the `current_user`'s `roles` list contains the `required_role` passed during its initialization.
    *   **Data in `conn`**: If the `current_user` does not have the required role, it halts the connection and sends a `403 Forbidden` response. Otherwise, it passes the `conn` through unchanged.

### Resource-Specific Authorization Plugs

For resources like `AIAnalyses`, `Briefs`, `Contacts`, and `CostEstimates`, there are dedicated authorization plugs that handle granular permissions based on ownership and user roles. These plugs typically:

*   `CopilotWeb.Plugs.AuthorizeAIAnalysis`
*   `CopilotWeb.Plugs.AuthorizeBrief`
*   `CopilotWeb.Plugs.AuthorizeContact`
*   `CopilotWeb.Plugs.AuthorizeCostEstimate`

    *   **Responsibility**: These plugs are designed to authorize access to specific instances of a resource (e.g., a particular project brief or cost estimate). They typically fetch the resource based on an ID from `conn.params` and then apply business logic to determine if the `current_user` (available via `conn.assigns.current_user`) is authorized to perform the requested action (e.g., `show`, `update`, `delete`). Authorization often involves checking if the user is a "developer" or the "owner" of the resource (by comparing `user.customer_id` with the resource's `customer_id`).
    *   **Data in `conn`**: If authorized, they assign the fetched resource struct to `conn.assigns` (e.g., `conn.assigns.ai_analysis`, `conn.assigns.brief`). If not authorized, they halt the connection and send a `403 Forbidden` response.

This detailed breakdown should help in correctly adding new endpoints to the appropriate security pipelines and understanding the available user information at each stage of the request lifecycle.