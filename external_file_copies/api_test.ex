defmodule ApiTest do
  @base_url "http://localhost:4000"
  @finch_pool_name ApiTest.Finch

  # --- Common Test Data ---
  @unique_part "#{System.os_time(:nanosecond)}-#{System.unique_integer([:positive])}"

  # --- Customer User Data ---
  @provider_id "api-test-#{@unique_part}"
  @email "api.test.user.#{@unique_part}@testmyapi.com"
  @name "TestMyApi Corp."

  # --- Developer User Data ---
  @developer_email "developer-#{@unique_part}@testmyapi.com"
  @developer_provider_id "dev-api-test-#{@unique_part}"
  @developer_name "Test Customer"

  # --- Project Data ---
  # Placeholder for a project ID. In a real scenario, this would be created via API or fetched.
  @project_id "00000000-0000-0000-0000-000000000001"

  def run do
    # Start Finch for our requests. This is idempotent.
    Finch.start_link(name: @finch_pool_name)

    results = [
      run_scenario_1(),
      run_scenario_2_developer_workflow()
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

  defp run_scenario_2_developer_workflow do
    IO.puts("\n--- Scenario 2: Semi-automatic developer role grant and time entry creation ---")

    # 1. Register the user who will become a developer
    registration_payload = %{
      "registration" => %{
        "provider_id" => @developer_provider_id,
        "email" => @developer_email,
        "name" => @developer_name,
        "company_name" => @developer_name
      }
    }

    IO.puts("Attempting to register a user to be promoted to developer:")
    IO.puts("  Provider ID: #{@developer_provider_id}")
    IO.puts("  Email:       #{@developer_email}")

    case register_user(registration_payload) do
      {:ok, %{status: status, body: %{data: {id: developer_user_id, customer_id: developer_customer_id}}}} when status in [200, 201] ->
        IO.inspect(body, label: "REGISTER USER RESPONSE BODY")
        IO.puts("✅ User registered successfully. Ready for promotion.")

        # The user ID and customer ID are needed for the time entry and project brief payloads.
        {:ok, %{"data" => %{"id" => developer_user_id, "customer_id" => developer_customer_id}}} = Jason.decode(body)
        IO.puts("   (Developer User ID: #{developer_user_id})")
        IO.puts("   (Developer Customer ID: #{developer_customer_id})")

        IO.puts("--------------------------------------------------------------------------")
        IO.puts("\n>>> MANUAL STEP REQUIRED <<<")
        IO.puts("In another terminal, please run the following command to grant the 'developer' role:")
        IO.puts("\n  mix users.grant_role #{@developer_email} developer\n")
        IO.gets("Press Enter to continue after you have run the mix task...")
        IO.puts("--------------------------------------------------------------------------")
        IO.puts("Resuming test...")
        case create_project_brief(developer_customer_id, developer_user_id) do
          {:ok, %{status: status, body: %{data: {project_brief}}}} when status in [200, 201] ->
            # 2. Proceed to create a time entry, passing the developer's user ID.
            run_time_entry_creation_test(developer_user_id, project_brief_id)
          {:ok, %{status: status, body: body}} ->
            IO.puts("Status Code: #{status}")
            IO.puts("Response Body: #{body}")
            IO.puts("\n--- ❌ FAIL: Could not create project brief. ---")
            :fail
          {:error, reason} ->
            IO.puts("Error:")
            IO.inspect(reason)
            :fail
        end
      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Could not register user to be promoted. ---")
        :fail
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Request to register user to be promoted failed. ---")
        :fail
    end
  end

  defp run_time_entry_creation_test(developer_user_id, customer_id, project_id) do
    IO.puts("\n--- Scenario 2.1: Create a time entry as a developer ---")

    time_entry_payload = %{
      "time_entry" => %{
        "developer_id" => developer_user_id,
        "project_id" => @project_id,
        "start_time" => "2025-08-11T09:00:00Z",
        "end_time" => "2025-08-11T10:30:00Z",
        "description" => "Initial project setup and configuration."
      }
    }

    IO.puts("Attempting to create a time entry with developer:")
    IO.puts("  Provider ID: #{@developer_provider_id}")

    case create_time_entry(time_entry_payload, @developer_provider_id) do
      {:ok, %{status: 201, body: body}} ->
        IO.puts("Status Code: 201")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Time entry created successfully. ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Time entry creation failed with status #{status} (expected 201) ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Time entry creation request failed. ---")
        :fail
    end
  end

  # --- HTTP Helper Functions ---

  defp make_request(method, path, headers, body) do
    url = @base_url <> path

    json_body = if body, do: Jason.encode!(body), else: nil

    default_headers = [
      {"Content-Type", "application/json"},
      {"Accept", "*/*"}
    ]

    final_headers = default_headers ++ headers

    request = Finch.build(method, url, final_headers, json_body)
    Finch.request(request, @finch_pool_name)
  end

  defp register_user(payload) do
    make_request(:post, "/api/register", [], payload)
  end



  defp create_project_brief(customer_id, developer_user_id) do
    auth_override_header =
      %{
        "provider_id" => @developer_provider_id,
        "email" => @developer_email,
        "name" => @developer_name,
        "roles" => ["developer", "user"],
        "customer_id" => customer_id
      }
      |> Jason.encode!()

    headers = [{"x-dev-auth-override", auth_override_header}]

    payload = %{
      "project_brief" => %{
        "title" => "API Test Project Brief - #{@unique_part}",
        "summary" => "This is a test project brief created via the API for scenario 2.",
        "description" => "This is a test project brief created via the API for scenario 2.",
        "customer_id" => customer_id,
        "developer_id" => developer_user_id
      }
    }
  end

  defp create_time_entry(payload) do
    auth_override_header =
      %{
        "provider_id" => @provider_id,
        "email" => @developer_email,
        "name" => @developer_name,
        "roles" => ["developer", "user"]
      }
      |> Jason.encode!()

    headers = [{"x-dev-auth-override", auth_override_header}]

    make_request(:post, "/api/time_entries", headers, payload)
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
