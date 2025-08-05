defmodule CopilotWeb.Plugs.UserInfo do
  @moduledoc """
  Extracts user information from a request header and loads the user.
  """
  import Plug.Conn

  alias Copilot.Core.Users
  alias Jason

  def init(opts), do: opts

  def call(conn, _opts) do
    with [user_info_json] <- get_req_header(conn, "x-user-info"),
         {:ok, user_attrs} <- Jason.decode(user_info_json),
         {:ok, user} <- Users.find_or_create_user(user_attrs) do
      assign(conn, :current_user, user)
    else
      _error ->
        # If the header is missing, JSON is invalid, or the user
        # can't be found/created, we assign nil.
        # The EnsureAuthenticated plug will then reject the request.
        assign(conn, :current_user, nil)
    end
  end
end
