defmodule CopilotApi.Core.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias CopilotApi.Repo
  alias CopilotApi.Core.Customers

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
          # This is a new user. Check their roles to see if a Customer should be created.
          roles = Map.get(attrs, "roles", ["customer", "user"])

          if "customer" in roles do
            # This is a customer user. Create a Customer for them.
            with {:ok, customer} <-
                   Customers.create_customer(%{name: %{company_name: attrs["name"]}}),
                 {:ok, user} <-
                   attrs
                   |> Map.put("customer_id", customer.id)
                   |> Map.put("roles", roles)
                   |> create_user() do
              Logger.info("New customer and user created", %{
                event: "customer_user_created",
                user_id: user.id,
                customer_id: customer.id,
                email: user.email
              })

              {:ok, user}
            end
          else
            # This is a non-customer user (e.g., a developer).
            # Create them without a customer record.
            with {:ok, user} <- attrs |> Map.put("roles", roles) |> create_user() do
              Logger.info("New non-customer user created", %{event: "non_customer_user_created", user_id: user.id, email: user.email})
              {:ok, user}
            end
          end

        user ->
          {:ok, user}
      end
    else
      # If provider_id is nil, we can't find a user.
      # Go straight to creation, which will fail validation as expected.
      create_user(Map.put_new(attrs, "roles", ["customer", "user"]))
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
