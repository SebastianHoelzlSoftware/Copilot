defmodule ApiTest do
  @base_url "http://localhost:4000"
  @finch_pool_name ApiTest.Finch

  @unique_part "#{System.os_time(:nanosecond)}-#{System.unique_integer([:positive])}"
  @provider_id "api-test-#{@unique_part}"
  @email "api.test.user.#{@unique_part}@testmyapi.com"
  @name "TestMyApi Corp."

  def run do
    # Start Finch for our requests. This is idempotent.
    Finch.start_link(name: @finch_pool_name)

    results = [
      run_scenario_1(),
    ]

    print_summary(results)
  end

  defp run_scenario_1 do
    IO.puts("--- Scenario 1: Register a new user via the public /api/register endpoint ---")

    payload = %{
      "registration" => %{
        "provider_id" => @provider_id,
        "email" => @email,
        "name" => @name,
        "company_name" => @name
      }
    }

    IO.puts("Attempting to register a customer-user with:")
    IO.puts("  Provider ID: #{@provider_id}")
    IO.puts("  Email:       #{@email}")
    IO.puts("  Name:        #{@name}")
    IO.puts("--------------------------------------------------------------------------")

    case register_user(payload) do
      {:ok, %{status: 201, body: body}} ->
        IO.puts("Status Code: 201")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Initial registration successful (201 Created) ---")

        IO.puts("\n--- Scenario 1.2: Attempt to register the same user again ---")
        case register_user(payload) do
          {:ok, %{status: 200, body: body2}} ->
            IO.puts("Status Code: 200")
            IO.puts("Response Body: #{body2}")
            IO.puts("\n--- ✅ PASS: Subsequent registration returned 200 OK ---")
            :pass
          {:ok, %{status: status_code2, body: body2}} ->
            IO.puts("Status Code: #{status_code2}")
            IO.puts("Response Body: #{body2}")
            IO.puts("\n--- ❌ FAIL: Subsequent registration failed with status #{status_code2} (expected 200) ---")
            :fail
          {:error, reason2} ->
            IO.puts("Error:")
            IO.inspect(reason2)
            IO.puts("\n--- ❌ FAIL: Subsequent registration request failed ---")
            :fail
        end
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Initial registration failed with status #{status_code} (expected 201) ---")
        :fail
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Initial registration request failed ---")
        :fail
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

  defp print_summary(results) do
    passes = Enum.count(results, &(&1 == :pass))
    fails = Enum.count(results, &(&1 == :fail))
    total = length(results)

    IO.puts("\n\n--- Test Summary ---")
    IO.puts("Total Scenarios: #{total}")
    IO.puts("✅ Passed:        #{passes}")

    if fails > 0 do
      IO.puts("❌ Failed:        #{fails}")
    end

    IO.puts("--------------------")
  end
end
