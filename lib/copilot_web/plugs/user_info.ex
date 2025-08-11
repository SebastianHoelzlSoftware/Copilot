defmodule CopilotWeb.Plugs.UserInfo do
  @moduledoc """
  Extracts user information from a request header and loads the user.
  """
  import Plug.Conn

  alias Copilot.Core.Users
  alias Jason

  def init(opts), do: opts

  def call(conn, opts) do
    user =
      if opts[:check_session] do
        if user_id = get_session(conn, :current_user_id) do
          Users.get_user(user_id)
        else
          nil
        end
      else
        nil
      end

    if user do
      assign(conn, :current_user, user)
    else
      # If not checking session, or user not found in session, try to get from header
      with [user_info_json] <- get_req_header(conn, "x-user-info"),
           {:ok, user_attrs} <- Jason.decode(user_info_json),
           {:ok, user_from_header} <- Users.find_or_create_user(user_attrs) do
        assign(conn, :current_user, user_from_header)
      else
        _error ->
          assign(conn, :current_user, nil)
      end
    end
  end
end
