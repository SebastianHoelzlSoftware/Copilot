defmodule Copilot.Repo.Migrations.ChangeUserRoleToRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :role
      add :roles, {:array, :string}, default: [], null: false
    end
  end
end
