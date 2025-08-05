defmodule CopilotWeb.RegistrationController do
  use CopilotWeb, :controller

  alias Copilot.Core.Users
  alias CopilotWeb.UserJSON

  action_fallback CopilotWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, {status, user}} <- Users.register_user(user_params) do
      conn
      |> put_status(status_to_code(status))
      |> put_view(json: UserJSON)
      |> render(:show, user: user)
    end
  end

  defp status_to_code(:created), do: :created
  defp status_to_code(:found), do: :ok
end
