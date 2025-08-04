defmodule Mix.Tasks.Users.GrantRole do
  @moduledoc """
  Grants a new role to a user.

  This task finds a user by their email and adds the specified role to their
  list of roles. If the user already has the role, the list remains unchanged.

  ## Examples

      mix users.grant_role developer@example.com developer

  """
  use Mix.Task

  @shortdoc "Grants a role to a user by email"

  @impl Mix.Task
  def run(args) do
    # We need to start our application to have access to the Repo
    Mix.Task.run("app.start")

    case parse_args(args) do
      {:ok, email, role} ->
        grant_role(email, role)

      {:error, reason} ->
        Mix.shell().error(reason)
        print_help()
        System.halt(1)
    end
  end

  defp parse_args(args) do
    case args do
      [email, role] -> {:ok, email, role}
      _ -> {:error, "Invalid arguments: Missing email or role."}
    end
  end

  defp grant_role(email, role) do
    alias CopilotApi.Core.Users

    case Users.get_user_by(email: email) do
      nil ->
        Mix.shell().error("❌ User with email '#{email}' not found.")
        System.halt(1)

      user ->
        new_roles = (user.roles ++ [role]) |> Enum.uniq() |> Enum.sort()

        case Users.update_user(user, %{roles: new_roles}) do
          {:ok, updated_user} ->
            Mix.shell().info("✅ Successfully granted role '#{role}' to user #{email}.")
            Mix.shell().info("   New roles: #{inspect(updated_user.roles)}")

          {:error, changeset} ->
            Mix.shell().error("❌ Could not update user: #{inspect(changeset.errors)}")
            System.halt(1)
        end
    end
  end

  defp print_help do
    Mix.shell().info("""
    Usage: mix users.grant_role <email> <role>
    """)
  end
end
