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
      {:ok, %{status: status, body: body}} when status in [200, 201] ->
        {:ok, %{"data" => %{"id" => developer_user_id, "customer_id" => developer_customer_id}}} = Jason.decode(body)
        IO.inspect(body, label: "REGISTER USER RESPONSE BODY")
        IO.inspect(body, label: "REGISTER USER RESPONSE BODY")
        IO.puts("✅ User registered successfully. Ready for promotion.")

        # The user ID and customer ID are needed for the time entry and project brief payloads.
        IO.inspect(developer_user_id, label: "developer_user_id")
        IO.inspect(developer_customer_id, label: "developer_customer_id")
        IO.puts("   (Developer User ID: #{developer_user_id})")
        IO.puts("   (Developer Customer ID: #{developer_customer_id})")

        IO.puts("--------------------------------------------------------------------------")
        IO.puts("\n>>> MANUAL STEP REQUIRED <<<")
        IO.puts("In another terminal, please run the following command to grant the 'developer' role:")
        IO.puts("\n  mix users.grant_role #{@developer_email} developer\n")
        IO.gets("Press Enter to continue after you have run the mix task...")
        IO.puts("--------------------------------------------------------------------------")
        IO.puts("Resuming test...")
        # Create a customer for the project brief
        customer_payload = %{
          "registration" => %{
            "provider_id" => "customer-for-brief-#{@unique_part}",
            "email" => "customer.brief.#{@unique_part}@testmyapi.com",
            "name" => "Project Brief Customer",
            "company_name" => "Project Brief Customer Corp."
          }
        }

        case register_user(customer_payload) do
          {:ok, %{status: status, body: body}} when status in [200, 201] ->
            {:ok, %{"data" => %{"id" => _customer_user_id, "customer_id" => project_brief_customer_id}}} = Jason.decode(body)
            IO.puts("✅ Customer for project brief registered successfully.")
            IO.puts("   (Project Brief Customer ID: #{project_brief_customer_id})")

            case create_project_brief(project_brief_customer_id, developer_user_id) do
              {:ok, project_brief_id} ->
                # 2. Proceed to create a time entry, passing the developer's user ID.
                case run_time_entry_creation_test(developer_user_id, project_brief_id) do
                  {:ok, time_entry_id} ->
                    run_time_entry_index_test(developer_user_id)
                    run_time_entry_show_test(time_entry_id, developer_user_id)
                    run_time_entry_update_test(time_entry_id, developer_user_id)
                    run_time_entry_delete_test(time_entry_id, developer_user_id)
                  :error ->
                    :fail
                end
              :error ->
                IO.puts("\n--- ❌ FAIL: Could not create project brief. ---")
                :fail
            end
          {:ok, %{status: status, body: body}} ->
            IO.puts("Status Code: #{status}")
            IO.puts("Response Body: #{body}")
            IO.puts("\n--- ❌ FAIL: Could not register customer for project brief. ---")
            :fail
          {:error, reason} ->
            IO.puts("Error:")
            IO.inspect(reason)
            IO.puts("\n--- ❌ FAIL: Request to register customer for project brief failed. ---")
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

  defp run_time_entry_creation_test(developer_user_id, project_brief_id) do
    IO.puts("\n--- Scenario 2.1: Create a time entry as a developer ---")

    time_entry_payload = %{
      "time_entry" => %{
        "developer_id" => developer_user_id,
        "project_id" => project_brief_id,
        "start_time" => "2025-08-11T09:00:00Z",
        "end_time" => "2025-08-11T10:30:00Z",
        "description" => "Initial project setup and configuration."
      }
    }

    IO.puts("Attempting to create a time entry with developer:")
    IO.puts("  Provider ID: #{@developer_provider_id}")

    case create_time_entry(time_entry_payload, @developer_provider_id) do
      {:ok, %{status: 201, body: body}} ->
        {:ok, %{"data" => %{"id" => time_entry_id}}} = Jason.decode(body)
        {:ok, time_entry_id}

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Time entry creation failed with status #{status} (expected 201) ---")
        :error

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Time entry creation request failed. ---")
        :error
    end
  end

  defp run_time_entry_index_test(developer_user_id) do
    IO.puts("\n--- Scenario 2.2: List time entries as a developer ---")

    case list_time_entries(developer_user_id) do
      {:ok, %{status: 200, body: body}} ->
        IO.puts("Status Code: 200")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Time entries listed successfully. ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Listing time entries failed with status #{status} (expected 200) ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Listing time entries request failed. ---")
        :fail
    end
  end

  defp run_time_entry_show_test(time_entry_id, developer_user_id) do
    IO.puts("\n--- Scenario 2.3: Show a specific time entry as a developer ---")

    case get_time_entry(time_entry_id, developer_user_id) do
      {:ok, %{status: 200, body: body}} ->
        IO.puts("Status Code: 200")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Time entry shown successfully. ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Showing time entry failed with status #{status} (expected 200) ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Showing time entry request failed. ---")
        :fail
    end
  end

  defp run_time_entry_update_test(time_entry_id, developer_user_id) do
    IO.puts("\n--- Scenario 2.4: Update a time entry as a developer ---")

    update_payload = %{
      "time_entry" => %{
        "description" => "Updated description for the time entry."
      }
    }

    case update_time_entry(time_entry_id, update_payload, developer_user_id) do
      {:ok, %{status: 200, body: body}} ->
        IO.puts("Status Code: 200")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ✅ PASS: Time entry updated successfully. ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Updating time entry failed with status #{status} (expected 200) ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Updating time entry request failed. ---")
        :fail
    end
  end

  defp run_time_entry_delete_test(time_entry_id, developer_user_id) do
    IO.puts("\n--- Scenario 2.5: Delete a time entry as a developer ---")

    case delete_time_entry(time_entry_id, developer_user_id) do
      {:ok, %{status: 204}} ->
        IO.puts("Status Code: 204")
        IO.puts("\n--- ✅ PASS: Time entry deleted successfully. ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ FAIL: Deleting time entry failed with status #{status} (expected 204) ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ FAIL: Deleting time entry request failed. ---")
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
      %{ "provider_id" => @developer_provider_id, "email" => @developer_email, "name" => @developer_name, "roles" => ["developer", "user"], "customer_id" => customer_id } |> Jason.encode!()

    headers = [{"x-dev-auth-override", auth_override_header}]

    payload = %{
      "project_brief" => %{
        "title" => "API Test Project Brief - #{@unique_part}",
        "summary" => "This is a test project brief created via the API for scenario 2.",
        "customer_id" => customer_id
      }
    }

    IO.inspect(payload, label: "create_project_brief payload")

    case make_request(:post, "/api/briefs", headers, payload) do
      {:ok, %{status: 201, body: body}} ->
        {:ok, %{"data" => %{"id" => project_brief_id}}} = Jason.decode(body)
        {:ok, project_brief_id}
      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("--- ❌ FAIL: Could not create project brief. ---")
        :error
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        :error
    end
  end

  defp create_time_entry(payload, developer_provider_id) do
    auth_header = %{
      "provider_id" => developer_provider_id,
      "email" => @developer_email,
      "name" => @developer_name,
      "roles" => ["developer", "user"]
    } |> Jason.encode!()

    headers = [{"x-user-info", auth_header}]

    make_request(:post, "/api/time_entries", headers, payload)
  end

  defp get_time_entry(time_entry_id, developer_provider_id) do
    auth_header = %{
      "provider_id" => developer_provider_id,
      "email" => @developer_email,
      "name" => @developer_name,
      "roles" => ["developer", "user"]
    } |> Jason.encode!()

    headers = [{"x-user-info", auth_header}]

    make_request(:get, "/api/time_entries/" <> time_entry_id, headers, nil)
  end

  defp update_time_entry(time_entry_id, payload, developer_provider_id) do
    auth_header = %{
      "provider_id" => developer_provider_id,
      "email" => @developer_email,
      "name" => @developer_name,
      "roles" => ["developer", "user"]
    } |> Jason.encode!()

    headers = [{"x-user-info", auth_header}]

    make_request(:put, "/api/time_entries/" <> time_entry_id, headers, payload)
  end

  defp delete_time_entry(time_entry_id, developer_provider_id) do
    auth_header = %{
      "provider_id" => developer_provider_id,
      "email" => @developer_email,
      "name" => @developer_name,
      "roles" => ["developer", "user"]
    } |> Jason.encode!()

    headers = [{"x-user-info", auth_header}]

    make_request(:delete, "/api/time_entries/" <> time_entry_id, headers, nil)
  end

  defp list_time_entries(developer_user_id) do
    auth_header = %{
      "provider_id" => @developer_provider_id,
      "email" => @developer_email,
      "name" => @developer_name,
      "roles" => ["developer", "user"]
    } |> Jason.encode!()

    headers = [{"x-user-info", auth_header}]

    make_request(:get, "/api/time_entries", headers, nil)
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
