defmodule APITest do
  def run do
    # Start Finch
    {:ok, _pid} = Finch.start_link(name: Copilot.Finch)

    # Define the payload for creating a new contact
    new_contact_payload = %{
      "contact" => %{
        "name" => %{
          "first_name" => "John",
          "last_name" => "Appleseed"
        },
        "email" => %{
          "address" => "john.appleseed@example.com"
        },
        "phone_number" => %{
          "number" => "+15551234567"
        }
      }
    }

    # Define the user info for authentication
    user_info_payload = %{
      "provider_id" => "new-customer-789",
      "email" => "new.customer@example.com",
      "name" => "New Customer Company",
      "roles" => ["customer", "user"]
    }

    # Convert payloads to JSON
    {:ok, new_contact_json} = Jason.encode(new_contact_payload)
    {:ok, user_info_json} = Jason.encode(user_info_payload)

    # Define headers
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "*/*"},
      {"x-dev-auth-override", user_info_json}
    ]

    # Build the request
    request = Finch.build(:post, "http://localhost:4000/api/contacts", headers, new_contact_json)

    # Make the HTTP request
    case Finch.request(request, Copilot.Finch) do
      {:ok, %{status: status_code, body: body}} ->
        IO.puts("Status Code: #{status_code}")
        IO.puts("Response Body: #{body}")
      {:error, reason} ->
        IO.puts("Request failed: #{reason}")
    end
  end
end

# Run the test
APITest.run()
