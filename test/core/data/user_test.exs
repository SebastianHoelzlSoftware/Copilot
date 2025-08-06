defmodule Copilot.Core.Data.UserTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Data.User
  import Ecto.Changeset

  describe "registration_changeset" do
    test "with valid attributes sets roles to customer and user" do
      attrs = %{
        "provider_id" => "test-provider-reg-1",
        "email" => "register@example.com",
        "name" => "Register User"
      }

      changeset = User.registration_changeset(%User{}, attrs)
      assert changeset.valid?
      assert get_change(changeset, :roles) == ["customer", "user"]
      assert get_change(changeset, :provider_id) == "test-provider-reg-1"
      assert get_change(changeset, :email) == "register@example.com"
      assert get_change(changeset, :name) == "Register User"
    end

    test "with invalid email format returns an error" do
      attrs = %{
        "provider_id" => "test-provider-reg-2",
        "email" => "invalid-email",
        "name" => "Invalid Email User"
      }

      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?
      assert "must have the @ sign and no spaces" in errors_on(changeset)[:email]
    end

    test "with missing required fields returns an error" do
      attrs = %{
        "email" => "missing@example.com",
        "name" => "Missing Provider"
      }

      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset)[:provider_id]

      attrs = %{
        "provider_id" => "test-provider-reg-3",
        "name" => "Missing Email"
      }

      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset)[:email]

      attrs = %{
        "provider_id" => "test-provider-reg-4",
        "email" => "missingname@example.com"
      }

      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset)[:name]
    end

    test "attempting to set developer role returns an error" do
      attrs = %{
        "provider_id" => "test-provider-reg-5",
        "email" => "developer@example.com",
        "name" => "Developer User",
        "roles" => ["developer"]
      }

      changeset = User.registration_changeset(%User{}, attrs)
      refute changeset.valid?

      assert "only 'customer' and 'user' roles are allowed for registration" in errors_on(
               changeset
             )[:roles]
    end

    test "with existing provider_id returns an error" do
      # Create a user first to simulate an existing provider_id
      _user =
        %User{}
        |> User.changeset(%{
          provider_id: "existing-provider",
          email: "existing@example.com",
          name: "Existing User",
          roles: ["customer"]
        })
        |> Repo.insert!()

      attrs = %{
        "provider_id" => "existing-provider",
        "email" => "new@example.com",
        "name" => "New User"
      }

      changeset =
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()

      assert {:error, %Ecto.Changeset{} = changeset} = changeset
      assert "has already been taken" in errors_on(changeset)[:provider_id]
    end

    test "with existing email returns an error" do
      # Create a user first to simulate an existing email
      _user =
        %User{}
        |> User.changeset(%{
          provider_id: "another-provider",
          email: "another@example.com",
          name: "Another User",
          roles: ["customer"]
        })
        |> Repo.insert!()

      attrs = %{
        "provider_id" => "new-provider",
        "email" => "another@example.com",
        "name" => "New User"
      }

      changeset =
        %User{}
        |> User.registration_changeset(attrs)
        |> Repo.insert()

      assert {:error, %Ecto.Changeset{} = changeset} = changeset
      assert "has already been taken" in errors_on(changeset)[:email]
    end
  end
end
