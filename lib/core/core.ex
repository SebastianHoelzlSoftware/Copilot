defmodule CopilotApi.Core do
  @moduledoc """
  The Core context.
  """
  import Ecto.Query, warn: false
  alias CopilotApi.Repo

  alias CopilotApi.Core.Data.User

  @doc """
  Gets a user by their provider ID, creating them if they don't exist.

  This function is idempotent. If a user with the given `provider_id`
  already exists, it will be returned. Otherwise, a new user will be
  created with the provided attributes.

  ## Examples

      iex> get_or_create_user(%{"user_id" => "123", "email" => "test@example.com"})
      {:ok, %User{}}

  """
  def get_or_create_user(attrs) do
    # The "user_id" from the JWT corresponds to our "provider_id"
    provider_id = attrs["user_id"]

    case Repo.get_by(User, provider_id: provider_id) do
      nil ->
        # The changeset expects a :provider_id field, but the JWT gives "user_id".
        # We need to transform the attributes before creating the user.
        user_attrs = Map.put(attrs, "provider_id", provider_id)

        %User{}
        |> User.changeset(user_attrs)
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end
end
