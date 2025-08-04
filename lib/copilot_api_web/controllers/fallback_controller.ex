defmodule CopilotApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CopilotApiWeb, :controller

  # This is the action that will be called when an action in another
  # controller fails to match.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CopilotApiWeb.ErrorJSON)
    |> render(:error, result: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn |> put_status(:not_found) |> put_view(json: CopilotApiWeb.ErrorJSON) |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: CopilotApiWeb.ErrorJSON)
    |> render(:"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: CopilotApiWeb.ErrorJSON)
    |> render(:"403")
  end

  # This clause must be last to act as a catch-all for any other
  # error tuples.
  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: CopilotApiWeb.ErrorJSON)
    |> render(:"500")
  end
end
