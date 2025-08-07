# Scenarios for API Test

## Scenario 1: Register a new user via the public /api/register endpoint

1. A new user registers via the public /api/register endpoint with invalid data -> Error (which?)
2. He registers with valid data -> 201 Created
3. The user registers with the exact same data -> 200 OK
4. The user registers with a different provider_id but the same email -> Error (which?)
5. The user creates a project brief -> 201 Created
6. A developer user updates that project brief -> 200 OK
7. The user updates the project brief -> 200 OK
