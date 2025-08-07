defmodule ApiTest do
  @base_url "http://localhost:4000"
  @finch_pool_name ApiTest.Finch

  def run do
    # Start Finch for our requests. This is idempotent.
    Finch.start_link(name: @finch_pool_name)

    run_scenario_1()
    run_scenario_2()
  end

  defp run_scenario_1 do
    IO.puts("--- Scenario 1: Register a new user via the public /api/register endpoint ---")

    provider_id = "elixir-test-#{System.unique_integer([:positive])}"
    email = "elixir.test.user.#{System.unique_integer([:positive])}@example.com"
    contact_email = "elixir.test.contact.#{System.unique_integer([:positive])}@example.com"

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
