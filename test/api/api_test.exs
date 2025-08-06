defmodule Copilot.Api.ApiTest do
  def run do
    # Start Finch
    {:ok, _pid} = Finch.start_link(name: Copilot.Finch)

    # Define the payload for registering a new user.
    # We use unique values for provider_id and email to ensure the test is re-runnable,
    # as these fields have unique constraints in the database.
    provider_id = "elixir-test-#{System.unique_integer([:positive])}"
    email = "elixir.test.user.#{System.unique_integer([:positive])}@example.com"
    contact_email = "elixir.test.contact.#{System.unique_integer([:positive])}@example.com"

    registration_payload = %{
      "registration" => %{
        "provider_id" => provider_id,
        "email" => email,
        "name" => "Elixir Test Company",
        "company_name" => "Elixir Test Company",
        "contact_first_name" => "Elixir",
        "contact_last_name" => "Test",
        "contact_email" => contact_email,
        "contact_phone_number" => "+15555555555"
      }
    }

    # Convert payload to JSON
    {:ok, registration_json} = Jason.encode(registration_payload)

    # Define headers for the registration request.
    # No authentication is needed for this public endpoint.
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "*/*"}
    ]

    # Build the request
    request = Finch.build(:post, "http://localhost:4000/api/register", headers, registration_json)

    # Make the HTTP request
    IO.puts("--- Scenario 1: Register a new user via the public /api/register endpoint ---")
    IO.puts("Attempting to register user with:")
    IO.puts("  Provider ID: #{provider_id}")
    IO.puts("  Email:       #{email}")
    IO.puts("--------------------------------------------------------------------------")

    case Finch.request(request, Copilot.Finch) do
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")

        # Basic verification
        if status_code == 201 do
          IO.puts("\n--- ✅ PASS: Registration successful (201 Created) ---")
        else
          IO.puts("\n--- ❌ FAIL: Registration failed with status #{status_code} ---")
        end
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Request failed ---")
    end

    # --- Scenario 2: Attempt to register the same user twice ---
    IO.puts("\n--- Scenario 2: Attempt to register the same user twice ---")
    IO.puts("--------------------------------------------------------------------------")

    # Use a unique but consistent payload for this scenario to avoid conflicts with previous runs.
    provider_id_dup = "elixir-test-duplicate-#{System.unique_integer([:positive])}"
    email_dup = "elixir.test.duplicate.#{System.unique_integer([:positive])}@example.com"

    duplicate_payload = %{
      "registration" => %{
        "provider_id" => provider_id_dup,
        "email" => email_dup,
        "name" => "Duplicate Test Co",
        "company_name" => "Duplicate Test Co",
        "contact_first_name" => "Duplicate",
        "contact_last_name" => "Test",
        "contact_email" => "contact.#{email_dup}",
        "contact_phone_number" => "+15551112222"
      }
    }

    {:ok, duplicate_json} = Jason.encode(duplicate_payload)
    request_dup = Finch.build(:post, "http://localhost:4000/api/register", headers, duplicate_json)

    # First attempt
    IO.puts("--> First attempt to register user with provider_id: #{provider_id_dup}")
    case Finch.request(request_dup, Copilot.Finch) do
      {:ok, %{status: 201}} ->
        IO.puts("--- ✅ PASS: First registration successful (201 Created) ---")

        # Second attempt with the same payload
        IO.puts("\n--> Second attempt to register same user. This should return 200 OK.")
        case Finch.request(request_dup, Copilot.Finch) do
          {:ok, %{status: 200}} ->
            IO.puts("Status Code: 200")
            IO.puts("\n--- ✅ PASS: Second registration successful (200 OK) ---")
          {:ok, %{status: status_code}} ->
            IO.puts("\n--- ❌ FAIL: Expected status 200, but got #{status_code} ---")
          {:error, reason} ->
            IO.puts("Error on second attempt: #{inspect(reason)}")
            IO.puts("\n--- ❌ FAIL: Second request failed unexpectedly ---")
        end
      {:ok, %{status: status_code}} ->
        IO.puts("\n--- ❌ FAIL: First registration failed with status #{status_code}. Cannot test duplicate case. ---")
      {:error, reason} ->
        IO.puts("Error on first attempt: #{inspect(reason)}")
        IO.puts("\n--- ❌ FAIL: First request failed unexpectedly. Cannot test duplicate case. ---")
    end
  end
end

# Run the test
Copilot.Api.ApiTest.run()
