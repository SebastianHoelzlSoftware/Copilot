defmodule CopilotApi.Core.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias CopilotApi.Repo

  alias CopilotApi.Core.Data.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user("some-uuid")
      %User{}

      iex> get_user("another-uuid")
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("some-uuid")
      %User{}

      iex> get_user!("another-uuid")
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by a clause.

  ## Examples

      iex> get_user_by(email: "foo@bar.com")
      %User{}

      iex> get_user_by(provider_id: "12345")
      %User{}
  """
  def get_user_by(clause), do: Repo.get_by(User, clause)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Finds a user by provider_id or creates one if it doesn't exist.
  This is useful for authentication callbacks.

  ## Examples

      iex> find_or_create_user(%{"provider_id" => "123", "email" => "test@example.com", "name" => "Test"})
      {:ok, %User{}}
  """
  def find_or_create_user(attrs) do
    provider_id = attrs["provider_id"]

    if provider_id do
      case get_user_by(provider_id: provider_id) do
        nil ->
          attrs_with_defaults = Map.update(attrs, "roles", ["user"], &(&1))
          create_user(attrs_with_defaults)

        user ->
          {:ok, user}
      end
    else
      # If provider_id is nil, we can't find a user.
      # Go straight to creation, which will fail validation as expected.
      attrs_with_defaults = Map.update(attrs, "roles", ["user"], &(&1))
      create_user(attrs_with_defaults)
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
