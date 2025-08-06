#!/bin/bash

# --- Configuration ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---
check() {
    local description=$1
    local status=$2
    if [ $status -eq 0 ]; then
        echo -e "  ${GREEN}✔ PASS:${NC} $description"
    else
        echo -e "  ${RED}✖ FAIL:${NC} $description"
        exit 1
    fi
}

echo "======================================================================="
echo " Scenario 1: Register a new user via the public /api/register endpoint"
echo "======================================================================="

# Capture the output of the curl command into a variable called RESPONSE
RESPONSE=$(curl -s --compressed --request POST \
  --url http://localhost:4000/api/register \
  --header 'Accept: */*' \
  --header 'Accept-Encoding: gzip, deflate, br' \
  --header 'Connection: keep-alive' \
  --header 'Content-Type: application/json' \
  --header 'User-Agent: EchoapiRuntime/1.1.0' \
  --data '{
    "registration": {
        "provider_id" : "new-customer-789",
        "email" : "new.customer@example.com",
        "name" : "New Customer Company",
        "company_name" : "New Customer Company",
        "contact_first_name" : "Jane",
        "contact_last_name" : "Doe",
        "contact_email" : "jane.doe@example.com",
        "contact_phone_number" : "+15557654321"
    }
}')

echo "--- /api/register Response ---"
echo "$RESPONSE"

# --- Parsing the response without jq ---
# Using `sed` to parse the JSON response. This approach is less robust than
# using a dedicated JSON parser like jq, but it works for simple, predictable
# JSON structures and avoids extra dependencies.

user_id=$(echo "$RESPONSE" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
customer_id=$(echo "$RESPONSE" | sed -n 's/.*"customer_id":"\([^"]*\)".*/\1/p')
contact_id=$(echo "$RESPONSE" | sed -n 's/.*"contact_id":"\([^"]*\)".*/\1/p')

echo
echo "--- Parsed IDs ---"
echo "User ID:     $user_id"
echo "Customer ID: $customer_id"
echo "Contact ID:  $contact_id"
echo

# --- Verification ---
test -n "$user_id" && test -n "$customer_id" && test -n "$contact_id"
check "Parsed all required IDs from registration response" $?

echo
echo "======================================================================="
echo " Scenario 2: Access a protected route (/api/me) using the new user"
echo "======================================================================="

# The DevAuth plug expects an 'x-user-info' header for authenticated routes.
# We will construct it using the data from the registration.
# Note: In a real production environment, an API Gateway would inject this
# header after validating a JWT or another auth token.
USER_INFO_PAYLOAD='{"provider_id": "new-customer-789", "email": "new.customer@example.com", "name": "New Customer Company", "roles": ["customer", "user"]}'

echo "--> Sending GET request to /api/me with x-dev-auth-override header"
ME_RESPONSE=$(curl -s --compressed --request GET \
  --url http://localhost:4000/api/me \
  --header 'Accept: */*' \
  --header "x-dev-auth-override: $USER_INFO_PAYLOAD")

echo "--- /api/me Response ---"
echo "$ME_RESPONSE"

# Parse and verify the response to ensure we got the correct user back.
me_user_id=$(echo "$ME_RESPONSE" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

echo
echo "--- /api/me Parsed ID ---"
echo "User ID from /me: $me_user_id"
echo

test -n "$me_user_id" && test "$user_id" == "$me_user_id"
check "User ID from /register matches /me endpoint" $?

echo
echo "======================================================================="
echo " Scenario 3: Create a new contact for the registered customer"
echo "======================================================================="

# The user from Scenario 2 is a customer and can create contacts.
# We will use the same USER_INFO_PAYLOAD for authentication.
NEW_CONTACT_PAYLOAD='{
    "contact": {
        "name": {
            "first_name": "John",
            "last_name": "Appleseed"
        },
        "email": {
            "address": "john.appleseed@example.com"
        },
        "phone_number": {
            "number": "+15551234567"
        }
    }
}'

echo "--> Sending POST request to /api/contacts"
CONTACT_RESPONSE_WITH_CODE=$(curl -s -w "\\n%{http_code}" --compressed --request POST \
  --url http://localhost:4000/api/contacts \
  --header 'Accept: */*' \
  --header 'Content-Type: application/json' \
  --header "x-dev-auth-override: $USER_INFO_PAYLOAD" \
  --data "$NEW_CONTACT_PAYLOAD")

contact_http_status=$(echo "$CONTACT_RESPONSE_WITH_CODE" | tail -n1)
contact_body=$(echo "$CONTACT_RESPONSE_WITH_CODE" | sed '$d')

echo "--- /api/contacts Response ---"
echo "Status Code: $contact_http_status"
echo "Body: $contact_body"
echo

test "$contact_http_status" -eq 201
check "Received 201 Created for new contact" $?

new_contact_id=$(echo "$contact_body" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')
test -n "$new_contact_id"
check "Parsed new contact ID from response" $?

echo
echo "======================================================================="
echo " Scenario 4: Attempt to access a developer-only route (/api/customers)"
echo "======================================================================="
echo "--> This should fail with a 403 Forbidden status."

# We use the same user, who does not have the 'developer' role.
# We use -w "\\n%{http_code}" to get the status code along with the body.
CUSTOMERS_RESPONSE_WITH_CODE=$(curl -s -w "\\n%{http_code}" --compressed --request GET \
  --url http://localhost:4000/api/customers \
  --header 'Accept: */*' \
  --header "x-dev-auth-override: $USER_INFO_PAYLOAD")

# The status code is the last line of the output
http_status=$(echo "$CUSTOMERS_RESPONSE_WITH_CODE" | tail -n1)
body=$(echo "$CUSTOMERS_RESPONSE_WITH_CODE" | sed '$d')

echo "--- /api/customers Response ---"
echo "Status Code: $http_status"
echo "Body: $body"
echo

test "$http_status" -eq 403
check "Received 403 Forbidden as expected for developer-only route" $?

test -n "$body"
check "Forbidden response has a non-empty body" $?
echo "$body" | grep -q '"error"'
check "Forbidden response body contains an 'error' key" $?

echo
echo -e "${GREEN}========================================="
echo -e " All API scenarios passed successfully! "
echo -e "=========================================${NC}"
