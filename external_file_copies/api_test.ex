defmodule ApiTest do
  @base_url "http://localhost:4000"
  @finch_pool_name ApiTest.Finch

  def run do
    # Start Finch for our requests. This is idempotent.
    Finch.start_link(name: @finch_pool_name)

    run_scenario_1()
    run_scenario_2()
    run_scenario_3()
    run_scenario_4()
    run_scenario_5()
  end

  defp run_scenario_1 do
    IO.puts("--- Scenario 1: Register a new user via the public /api/register endpoint ---")

    unique_part = "#{System.os_time(:nanosecond)}-#{System.unique_integer([:positive])}"
    provider_id = "elixir-test-#{unique_part}"
    email = "elixir.test.user.#{unique_part}@example.com"
    contact_email = "elixir.test.contact.#{unique_part}@example.com"

    payload = %{
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

    IO.puts("Attempting to register user with:")
    IO.puts("  Provider ID: #{provider_id}")
    IO.puts("  Email:       #{email}")
    IO.puts("--------------------------------------------------------------------------")

    case register_user(payload) do
      {:ok, %{status: 201, body: body}} ->
        IO.puts("Status Code: 201")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Registration successful (201 Created) ---")
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Registration failed with status #{status_code} ---")
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Request failed ---")
    end
  end

  defp run_scenario_2 do
    IO.puts("\n--- Scenario 2: Attempt to register the same user twice ---")
    IO.puts("--------------------------------------------------------------------------")

    provider_id_dup = "elixir-test-duplicate-#{System.unique_integer([:positive])}"
    email_dup = "elixir.test.duplicate.#{System.unique_integer([:positive])}@example.com"

    payload = %{
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

    IO.puts("--> First attempt to register user with provider_id: #{provider_id_dup}")
    case register_user(payload) do
      {:ok, %{status: 201}} ->
        IO.puts("--- ✅ PASS: First registration successful (201 Created) ---")

        IO.puts("\n--> Second attempt to register same user. This should return 200 OK.")
        case register_user(payload) do
          {:ok, %{status: 200, body: body}} ->
            IO.puts("Status Code: 200")
            IO.puts("Response Body: #{body}")
            IO.puts("\n--- ✅ PASS: Second registration successful (200 OK) ---")
          {:ok, %{status: status_code, body: body}} ->
            IO.puts("Status Code: #{status_code}")
            IO.puts("Response Body: #{body}")
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

  defp run_scenario_3 do
    IO.puts("\n--- Scenario 3: Attempt to register a user with invalid data (missing provider_id) ---")
    IO.puts("--------------------------------------------------------------------------")

    # Missing provider_id which is a required field
    payload = %{
      "registration" => %{
        "email" => "invalid.user@example.com",
        "name" => "Invalid Test Co",
        "company_name" => "Invalid Test Co",
        "contact_first_name" => "Invalid",
        "contact_last_name" => "Test",
        "contact_email" => "contact.invalid@example.com",
        "contact_phone_number" => "+15553334444"
      }
    }

    IO.puts("Attempting to register user with invalid payload (missing provider_id)...")

    case register_user(payload) do
      {:ok, %{status: 422, body: body}} ->
        IO.puts("Status Code: 422")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Registration failed as expected with 422 Unprocessable Entity ---")
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Expected status 422, but got #{status_code} ---")
      {:error, reason} ->
        IO.puts("Error: #{inspect(reason)}")
        IO.puts("\n--- ❌ FAIL: Request failed unexpectedly ---")
    end
  end

  defp run_scenario_4 do
    IO.puts("\n--- Scenario 4: Attempt to register a user with an empty provider_id ---")
    IO.puts("--------------------------------------------------------------------------")

    payload = %{
      "registration" => %{
        "provider_id" => "",
        "email" => "empty.provider@example.com",
        "name" => "Empty Provider Test Co",
        "company_name" => "Empty Provider Test Co",
        "contact_first_name" => "Empty",
        "contact_last_name" => "Provider",
        "contact_email" => "contact.empty.provider@example.com",
        "contact_phone_number" => "+15556667777"
      }
    }

    IO.puts("Attempting to register user with an empty provider_id...")

    case register_user(payload) do
      {:ok, %{status: 422, body: body}} ->
        IO.puts("Status Code: 422")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Registration failed as expected with 422 Unprocessable Entity ---")
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Expected status 422, but got #{status_code} ---")
      {:error, reason} ->
        IO.puts("Error: #{inspect(reason)}")
        IO.puts("\n--- ❌ FAIL: Request failed unexpectedly ---")
    end
  end

  defp run_scenario_5 do
    IO.puts("\n--- Scenario 5: Attempt to register a user with a missing email ---")
    IO.puts("--------------------------------------------------------------------------")

    payload = %{
      "registration" => %{
        "provider_id" => "elixir-test-#{System.unique_integer([:positive])}",
        "name" => "Missing Email Test Co",
        "company_name" => "Missing Email Test Co",
        "contact_first_name" => "Missing",
        "contact_last_name" => "Email",
        "contact_email" => "contact.missing.email@example.com",
        "contact_phone_number" => "+15558889999"
      }
    }

    IO.puts("Attempting to register user with a missing email...")

    case register_user(payload) do
      {:ok, %{status: 422, body: body}} ->
        IO.puts("Status Code: 422")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Registration failed as expected with 422 Unprocessable Entity ---")
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Expected status 422, but got #{status_code} ---")
      {:error, reason} ->
        IO.puts("Error: #{inspect(reason)}")
        IO.puts("\n--- ❌ FAIL: Request failed unexpectedly ---")
    end
  end

  defp register_user(payload) do
    url = @base_url <> "/api/register"
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "*/*"}
    ]

    with {:ok, json_body} <- Jason.encode(payload),
         request <- Finch.build(:post, url, headers, json_body) do
      Finch.request(request, @finch_pool_name)
    else
      {:error, reason} -> {:error, "Failed to encode payload or build request: #{inspect(reason)}"}
    end
  end
end
