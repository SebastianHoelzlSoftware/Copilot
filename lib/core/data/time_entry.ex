defmodule Copilot.Core.Data.TimeEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Copilot.Core.Data.ProjectBrief
  alias Copilot.Core.Data.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "time_entries" do
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime
    field :description, :string

    belongs_to :developer, User
    belongs_to :project, ProjectBrief

    timestamps()
  end

  @doc false
  def changeset(time_entry, attrs) do
    time_entry
    |> cast(attrs, [:start_time, :end_time, :description, :developer_id, :project_id])
    |> validate_required([:start_time, :end_time, :developer_id, :project_id])
    |> foreign_key_constraint(:developer_id)
    |> foreign_key_constraint(:project_id)
    |> validate_end_time_after_start_time()
  end

  defp validate_end_time_after_start_time(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    if start_time && end_time && NaiveDateTime.compare(end_time, start_time) in [:lt, :eq] do
      add_error(changeset, :end_time, "must be after start time")
    else
      changeset
    end
  end
end
