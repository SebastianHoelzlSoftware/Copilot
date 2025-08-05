defmodule CopilotWeb.UserJSON do
  alias Copilot.Core.Data.User

  @doc """
  Renders the current user's data.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      roles: user.roles
    }
  end
end
