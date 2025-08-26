defmodule CopilotWeb.Plugs.DevAuthTest do
  use CopilotWeb.ConnCase, async: true

  alias CopilotWeb.Plugs.DevAuth

  test "injects default developer payload when no override is present", %{conn: conn} do
    conn = DevAuth.call(conn, [])
    [user_info] = get_req_header(conn, "x-user-info")
    decoded = Jason.decode!(user_info)

    assert decoded["email"] == "dev@copilot.com"
    assert "developer" in decoded["roles"]
  end

  test "uses override header if present", %{conn: conn} do
    override_payload = %{
      "provider_id" => "override-user-456",
      "email" => "override@example.com",
      "name" => "Override User",
      "roles" => ["customer"]
    }

    conn =
      conn
      |> put_req_header("x-dev-auth-override", Jason.encode!(override_payload))
      |> DevAuth.call([])

    [user_info] = get_req_header(conn, "x-user-info")
    decoded = Jason.decode!(user_info)

    assert decoded["email"] == "override@example.com"
    assert decoded["roles"] == ["customer"]
    # Ensure the override header is removed
    assert get_req_header(conn, "x-dev-auth-override") == []
  end
end
