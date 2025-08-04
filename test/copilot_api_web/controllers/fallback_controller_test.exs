defmodule CopilotApiWeb.FallbackControllerTest do
  use CopilotApiWeb.ConnCase, async: true

  alias CopilotApiWeb.FallbackController

  setup %{conn: conn} do
    # When calling a controller directly, the connection parameters are not
    # automatically parsed, and the response format is not set. We must
    # fetch the params and set the format manually to allow `render` to work.
    conn = conn
    |> Plug.Conn.fetch_query_params()
    |> put_private(:phoenix_format, "json")
    {:ok, conn: conn}
  end

  test "handles changeset errors with 422", %{conn: conn} do
    changeset =
      %Ecto.Changeset{
        valid?: false,
        errors: [field: {"is invalid", [validation: :required]}]
      }

    conn = FallbackController.call(conn, {:error, changeset})

    assert conn.status == 422

    assert json_response(conn, 422) == %{
             "errors" => %{"field" => ["is invalid"]}
           }
  end

  test "handles changeset errors with a string message", %{conn: conn} do
    # This simulates an error from a delete operation with constraints,
    # which produces a string-based error in the changeset.
    changeset =
      %Ecto.Changeset{
        valid?: false,
        errors: [base: "cannot be deleted due to associations"]
      }

    conn = FallbackController.call(conn, {:error, changeset})

    assert conn.status == 422
    assert json_response(conn, 422) == %{
             "errors" => %{"base" => ["cannot be deleted due to associations"]}
           }
  end

  test "handles not_found errors with 404", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :not_found})

    assert conn.status == 404
    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
  end

  test "handles unauthorized errors with 401", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :unauthorized})

    assert conn.status == 401
    assert json_response(conn, 401) == %{"errors" => %{"detail" => "Unauthorized"}}
  end

  test "handles forbidden errors with 403", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :forbidden})

    assert conn.status == 403
    assert json_response(conn, 403) == %{"errors" => %{"detail" => "Forbidden"}}
  end

  test "handles other errors with 500", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :some_unexpected_error})

    assert conn.status == 500
    assert json_response(conn, 500) == %{"errors" => %{"detail" => "Internal Server Error"}}
  end

  test "returns an error for unknown actions", %{conn: conn} do
    assert_raise Plug.Conn.WrapperError, fn ->
      # We must set the action in the conn's private assigns to simulate a router dispatch
      FallbackController.action(put_private(conn, :phoenix_action, :non_existent_action), [])
    end
  end
end
