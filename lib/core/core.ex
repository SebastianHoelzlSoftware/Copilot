defmodule CopilotApi.Core do
  @moduledoc """
  The Core context.
  """
  import Ecto.Query, warn: false
  alias CopilotApi.Repo

  alias CopilotApi.Core.Data.User

  @doc """
  Finds a user by their provider ID, creating or updating them as needed.

  This function is idempotent.
  - If a user with the given `provider_id` exists, their details (name, email, role)
    are updated with the latest information from the JWT claims.
  - If the user does not exist, a new one is created.

  ## Examples

      iex> upsert_user(%{"user_id" => "123", "email" => "test@example.com", "role" => "admin"})
      {:ok, %User{}}

  """
  def upsert_user(attrs) do
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
        # User exists, so we update their details from the JWT claims
        # in case their name or role has changed.
        user
        |> User.changeset(attrs)
        |> Repo.update()
    end
  end
end
