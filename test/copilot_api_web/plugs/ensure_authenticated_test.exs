defmodule CopilotApiWeb.Plugs.EnsureAuthenticatedTest do
  use CopilotApiWeb.ConnCase, async: true

  alias CopilotApiWeb.Plugs.EnsureAuthenticated

  test "halts the connection if no user is assigned", %{conn: conn} do
    # Don't assign a user
    conn = EnsureAuthenticated.call(conn, [])

    assert conn.halted
    assert conn.status == 401
    assert json_response(conn, 401)["error"]["code"] == "unauthorized"
  end

  test "continues the connection if a user is assigned", %{conn: conn} do
    conn = assign(conn, :current_user, %{})
    conn_after_plug = EnsureAuthenticated.call(conn, [])

    refute conn_after_plug.halted
  end
end
