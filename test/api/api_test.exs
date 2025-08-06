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
    IO.puts("--- Scenario: Register a new user via the public /api/register endpoint ---")
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
  end
end

# Run the test
Copilot.Api.ApiTest.run()
