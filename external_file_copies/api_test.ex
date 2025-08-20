defmodule ApiTest do
  @base_url "http://localhost:4000"
  @finch_pool_name ApiTest.Finch

  # --- Test Data Generation ---
  defp unique_part, do: "#{System.os_time(:nanosecond)}-#{System.unique_integer([:positive])}"

  defp customer_user_data do
    unique = unique_part()
    %{
      provider_id: "api-test-#{unique}",
      email: "api.test.user.#{unique}@testmyapi.com",
      name: "TestMyApi Corp."
    }
  end

  defp developer_user_data do
    unique = unique_part()
    %{
      provider_id: "dev-api-test-#{unique}",
      email: "developer-#{unique}@testmyapi.com",
      name: "Test Developer"
    }
  end



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
    IO.puts("\n\n=============================================================================")
    IO.puts("=== #{cyan("Scenario 1: Register a new user via the public /api/register endpoint")} ===")
    IO.puts("=============================================================================")

    customer_data = customer_user_data()

    payload = %{
      "registration" => %{
        "provider_id" => customer_data.provider_id,
        "email" => customer_data.email,
        "name" => customer_data.name,
        "company_name" => customer_data.name
      }
    }

    IO.puts("Attempting to register a customer-user with:")
    IO.puts("  Provider ID: #{customer_data.provider_id}")
    IO.puts("  Email:       #{customer_data.email}")
    IO.puts("  Name:        #{customer_data.name}")
    IO.puts("--------------------------------------------------------------------------")

    case register_user(payload) do
      {:ok, %{status: 201, body: _body}} ->
        IO.puts("\n--- ✅ #{green("PASS: Initial registration successful (201 Created)")} ---")

        IO.puts("\n#{cyan("*** Scenario 1.2: Attempt to register the same user again ***")}")
        case register_user(payload) do
          {:ok, %{status: 200, body: _body2}} ->
            IO.puts("\n--- ✅ #{green("PASS: Subsequent registration returned 200 OK ")} ---")
            :pass
          {:ok, %{status: status_code2, body: body2}} ->
            IO.puts("Status Code: #{status_code2}")
            IO.puts("Response Body: #{body2}")
            IO.puts("\n--- ❌ #{red("FAIL: Subsequent registration failed with status #{status_code2} (expected 200)")} ---")
            :fail
          {:error, reason2} ->
            IO.puts("Error:")
            IO.inspect(reason2)
            IO.puts("\n--- ❌ #{red("FAIL: Subsequent registration request failed")} ---")
            :fail
        end
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Initial registration failed with status #{status_code} (expected 201)")} ---")
        :fail
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Initial registration request failed")} ---")
        :fail
    end
  end

  defp run_scenario_2_developer_workflow do
    IO.puts("\n\n==================================================================================")
    IO.puts("=== #{cyan("Scenario 2: Semi-automatic developer role grant and time entry creation")} ===")
    IO.puts("==================================================================================")

    developer_data = developer_user_data()

    # 1. Register the user who will become a developer
    registration_payload = %{
      "registration" => %{
        "provider_id" => developer_data.provider_id,
        "email" => developer_data.email,
        "name" => developer_data.name,
        "company_name" => developer_data.name
      }
    }

    IO.puts("Attempting to register a user to be promoted to developer:")
    IO.puts("  Provider ID: #{developer_data.provider_id}")
    IO.puts("  Email:       #{developer_data.email}")

    case register_user(registration_payload) do
      {:ok, %{status: status, body: body}} when status in [200, 201] ->
        {:ok, %{"data" => %{"id" => developer_user_id, "customer_id" => developer_customer_id}}} = Jason.decode(body)
        IO.puts("✅ #{green("User registered successfully. Ready for promotion.")}")
        IO.puts("   (Developer User ID: #{developer_user_id})")
        IO.puts("   (Developer User ID: #{developer_user_id})")
        IO.puts("   (Developer Customer ID: #{developer_customer_id})")

        IO.puts("--------------------------------------------------------------------------")
        IO.puts("\n#{blue(">>> MANUAL STEP REQUIRED <<<")}")
        IO.puts("In another terminal, please run the following command to grant the 'developer' role:")
        IO.puts("\n  #{blue("mix users.grant_role #{developer_data.email} developer")}\n")
        IO.gets("Press #{blue("Enter")} to continue after you have run the mix task...")
        IO.puts("--------------------------------------------------------------------------")
        IO.puts("#{blue("Resuming test...\n")}")
        # Create a customer for the project brief
        customer_payload = %{
          "registration" => %{
            "provider_id" => "customer-for-brief-#{unique_part()}",
            "email" => "customer.brief.#{unique_part()}@testmyapi.com",
            "name" => "Project Brief Customer",
            "company_name" => "Project Brief Customer Corp."
          }
        }

        case register_user(customer_payload) do
          {:ok, %{status: status, body: body}} when status in [200, 201] ->
            {:ok, %{"data" => %{"id" => _customer_user_id, "customer_id" => project_brief_customer_id}}} = Jason.decode(body)
            IO.puts("✅ #{green("Customer for project brief registered successfully.")}")
            IO.puts("   (Project Brief Customer ID: #{project_brief_customer_id})")

            case create_project_brief(project_brief_customer_id, developer_user_id, developer_data) do
              {:ok, project_brief_id} ->
                # 2. Proceed to create a time entry, passing the developer's user ID.
                case run_time_entry_creation_test(developer_user_id, project_brief_id, developer_data) do
                  {:ok, time_entry_id} ->
                    run_time_entry_index_test(developer_data)
                    run_time_entry_show_test(time_entry_id, developer_data)
                    run_time_entry_update_test(time_entry_id, developer_data)
                    run_time_entry_delete_test(time_entry_id, developer_data)
                  :error ->
                    :fail
                end
              :error ->
                IO.puts("\n--- ❌ #{red("FAIL: Could not create project brief.")} ---")
                :fail
            end
          {:ok, %{status: status, body: body}} ->
            IO.puts("Status Code: #{status}")
            IO.puts("Response Body: #{body}")
            IO.puts("\n--- ❌ #{red("FAIL: Could not register customer for project brief.")} ---")
            :fail
          {:error, reason} ->
            IO.puts("Error:")
            IO.inspect(reason)
            IO.puts("\n--- ❌ #{red("FAIL: Request to register customer for project brief failed.")} ---")
            :fail
        end
      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Could not register user to be promoted. ")} ---")
        :fail
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Request to register user to be promoted failed.")} ---")
        :fail
    end
  end

  defp run_time_entry_creation_test(developer_user_id, project_brief_id, developer_data) do
    IO.puts("\n#{cyan("*** Scenario 2.1: Create a time entry as a developer ***")}")

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
    IO.puts("  Provider ID: #{developer_data.provider_id}")

        case create_time_entry(time_entry_payload, developer_data) do
      {:ok, %{status: 201, body: body}} ->
        {:ok, %{"data" => %{"id" => time_entry_id}}} = Jason.decode(body)
        {:ok, time_entry_id}

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Time entry creation failed with status #{status} (expected 201)")} ---")
        :error

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Time entry creation request failed. ")}---")
        :error
    end
  end

  defp run_time_entry_index_test(developer_user_id) do
    IO.puts("\n#{cyan("*** Scenario 2.2: List time entries as a developer ***")}")

    case list_time_entries(developer_user_id) do
      {:ok, %{status: 200, body: _body}} ->
        IO.puts("\n--- ✅ #{green("PASS: Time entries listed successfully. ")} ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Listing time entries failed with status #{status} (expected 200) ")} ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Listing time entries request failed. ")} ---")
        :fail
    end
  end

  defp run_time_entry_show_test(time_entry_id, developer_user_id) do
    IO.puts("\n#{cyan("*** Scenario 2.3: Show a specific time entry as a developer ***")}")

    case get_time_entry(time_entry_id, developer_user_id) do
      {:ok, %{status: 200, body: _body}} ->
        IO.puts("\n--- ✅ #{green("PASS: Time entry shown successfully.")} ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Showing time entry failed with status #{status} (expected 200)")} ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Showing time entry request failed.")} ---")
        :fail
    end
  end

  defp run_time_entry_update_test(time_entry_id, developer_user_id) do
    IO.puts("\n#{cyan("*** Scenario 2.4: Update a time entry as a developer ***")}")

    update_payload = %{
      "time_entry" => %{
        "description" => "Updated description for the time entry."
      }
    }

    case update_time_entry(time_entry_id, update_payload, developer_user_id) do
      {:ok, %{status: 200, body: _body}} ->
        IO.puts("\n--- ✅ #{green("PASS: Time entry updated successfully.")} ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Updating time entry failed with status #{status} (expected 200)")} ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Updating time entry request failed.")} ---")
        :fail
    end
  end

  defp run_time_entry_delete_test(time_entry_id, developer_user_id) do
    IO.puts("\n#{cyan("*** Scenario 2.5: Delete a time entry as a developer ***")}")

    case delete_time_entry(time_entry_id, developer_user_id) do
      {:ok, %{status: 204}} ->
        IO.puts("\n--- ✅ #{green("PASS: Time entry deleted successfully.")} ---")
        :pass

      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("\n--- ❌ #{red("FAIL: Deleting time entry failed with status #{status} (expected 204)")} ---")
        :fail

      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        IO.puts("\n--- ❌ #{red("FAIL: Deleting time entry request failed.")} ---")
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



  defp create_project_brief(customer_id, _developer_user_id, developer_data) do
    auth_override_header =
      %{ "provider_id" => developer_data.provider_id, "email" => developer_data.email, "name" => developer_data.name, "roles" => ["developer", "user"], "customer_id" => customer_id } |> Jason.encode!()

    headers = [{"x-dev-auth-override", auth_override_header}]

    payload = %{
      "project_brief" => %{
        "title" => "API Test Project Brief - #{unique_part()}",
        "summary" => "This is a test project brief created via the API for scenario 2.",
        "customer_id" => customer_id
      }
    }

    case make_request(:post, "/api/briefs", headers, payload) do
      {:ok, %{status: 201, body: body}} ->
        {:ok, %{"data" => %{"id" => project_brief_id}}} = Jason.decode(body)
        {:ok, project_brief_id}
      {:ok, %{status: status, body: body}} ->
        IO.puts("Status Code: #{status}")
        IO.puts("Response Body: #{body}")
        IO.puts("--- ❌ #{red("FAIL: Could not create project brief.")} ---")
        :error
      {:error, reason} ->
        IO.puts("Error:")
        IO.inspect(reason)
        :error
    end
  end

  defp create_time_entry(payload, developer_data) do
    headers = auth_headers_for(developer_data)
    make_request(:post, "/api/time_entries", headers, payload)
  end

  defp get_time_entry(time_entry_id, developer_data) do
    headers = auth_headers_for(developer_data)
    make_request(:get, "/api/time_entries/" <> time_entry_id, headers, nil)
  end

  defp update_time_entry(time_entry_id, payload, developer_data) do
    headers = auth_headers_for(developer_data)
    make_request(:put, "/api/time_entries/" <> time_entry_id, headers, payload)
  end

  defp delete_time_entry(time_entry_id, developer_data) do
    headers = auth_headers_for(developer_data)
    make_request(:delete, "/api/time_entries/" <> time_entry_id, headers, nil)
  end

  defp list_time_entries(developer_data) do
    headers = auth_headers_for(developer_data)
    make_request(:get, "/api/time_entries", headers, nil)
  end

  defp auth_headers_for(user_data, extra_claims \\ %{}) do
    base_claims = %{
      "provider_id" => user_data.provider_id,
      "email" => user_data.email,
      "name" => user_data.name,
      "roles" => ["developer", "user"]
    }

    auth_override_header = Map.merge(base_claims, extra_claims) |> Jason.encode!()
    [{"x-dev-auth-override", auth_override_header}]
  end

  defp blue(string) do
    "#{IO.ANSI.blue()}#{string}#{IO.ANSI.reset()}"
  end

  defp green(string) do
    "#{IO.ANSI.green()}#{string}#{IO.ANSI.reset()}"
  end

  defp red(string) do
    "#{IO.ANSI.red()}#{string}#{IO.ANSI.reset()}"
  end

  defp cyan(string) do
    "#{IO.ANSI.cyan()}#{string}#{IO.ANSI.reset()}"
  end

  defp magenta(string) do
    "#{IO.ANSI.magenta()}#{string}#{IO.ANSI.reset()}"
  end


  defp print_summary(results) do
    passes = Enum.count(results, &(&1 == :pass))
    fails = Enum.count(results, &(&1 == :fail))
    total = length(results)

    IO.puts("\n\n--- Test Summary ---")
    IO.puts("Total Scenarios: #{magenta(to_string(total))}")
    IO.puts("✅ #{green("Passed:")}        #{green(to_string(passes))}")

    if fails > 0 do
      IO.puts("❌ #{red("Failed:")}        #{red(to_string(fails))}")
    end

    IO.puts("--------------------")
  end
end
