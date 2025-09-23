defmodule CopilotWeb.Plugs.AssignUserToSession do
  @moduledoc """
  This plug is responsible for taking the `current_user` from the connection's
  assigns (which should have been populated by a preceding authentication plug
  like `DevAuth` or a production equivalent) and putting the user's ID into
  the session.
  
  This allows LiveView to re-establish the user's identity when it connects,
  as it only has access to the session data.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn.assigns[:current_user]
    |> then(&if &1, do: put_session(conn, :current_user_id, &1.id), else: conn)
  end
end
