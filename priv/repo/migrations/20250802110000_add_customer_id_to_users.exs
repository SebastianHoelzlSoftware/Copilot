defmodule CopilotApi.Repo.Migrations.AddCustomerIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id)
    end
  end
end
