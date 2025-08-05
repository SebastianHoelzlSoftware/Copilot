defmodule Copilot.Core.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Copilot.Repo
  alias Copilot.Core.Customers
  alias Copilot.Core.Contacts

  alias Copilot.Core.Data.User

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
  Registers a user by finding them by provider_id or creating a new one.

  If the user is new and has the "customer" role, a corresponding Customer
  record is also created. This entire operation is performed in a transaction.

  Returns:
  - `{:ok, {:created, user}}` if a new user was created.
  - `{:ok, {:found, user}}` if an existing user was found.
  - `{:error, changeset}` if there was a validation error.
  """
  def register_user(attrs) do
    provider_id = attrs["provider_id"]

    if is_nil(provider_id) do
      # If provider_id is nil, we can't find a user.
      # Go straight to creation, which will fail validation as expected.
      create_user(attrs)
      |> case do
        # This path should not be hit with invalid data, but we handle it for completeness.
        {:ok, user} -> {:ok, {:created, user}}
        {:error, changeset} -> {:error, changeset}
      end
    else
      case get_user_by(provider_id: provider_id) do
        nil ->
          # This is a new user. Create them within a transaction.
          create_user_for_registration(attrs)

        user ->
          # User already exists, return them.
          {:ok, {:found, user}}
      end
    end
  end

  defp create_user_for_registration(attrs) do
    Repo.transaction(fn ->
      user_attrs_with_customer =
        if "customer" in Map.get(attrs, "roles", []) do
          # Create a customer record first.
          customer_attrs = %{name: %{company_name: attrs["name"]}}

          case Customers.create_customer(customer_attrs) do
            {:ok, customer} -> Map.put(attrs, "customer_id", customer.id)
            {:error, changeset} -> Repo.rollback(changeset)
          end
        else
          attrs
        end

      case create_user(user_attrs_with_customer) do
        {:ok, user} -> {:created, user}
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
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

  @doc """
  Creates a user, customer, and contact in a single transaction.
  """
  def create_user_with_customer_and_contact(user_attrs, customer_attrs, contact_attrs) do
    Repo.transaction(fn ->
      # Create customer
      case Customers.create_customer(customer_attrs) do
        {:ok, customer} ->
          # Create contact associated with the customer
          contact_attrs_with_customer = Map.put(contact_attrs, :customer_id, customer.id)
          case Contacts.create_contact(contact_attrs_with_customer) do
            {:ok, contact} ->
              # Create user associated with the customer and default roles
              user_attrs_with_customer_and_roles =
                user_attrs
                |> Map.put(:customer_id, customer.id)
                |> Map.put_new(:roles, ["customer", "user"])

              case create_user(user_attrs_with_customer_and_roles) do
                {:ok, user} ->
                  {:ok, user, customer, contact}
                {:error, changeset} ->
                  Repo.rollback({:error, :user, changeset})
              end
            {:error, changeset} ->
              Repo.rollback({:error, :contact, changeset})
          end
        {:error, changeset} ->
          Repo.rollback({:error, :customer, changeset})
      end
    end)
  end
end
