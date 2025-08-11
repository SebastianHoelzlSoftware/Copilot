defmodule Copilot.Core.Data.TimeEntryTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Data.TimeEntry

  import Copilot.Core.Fixtures

  describe "changeset/2" do
    test "creates a valid changeset with valid nested attributes" do
      project_brief_fixture = project_brief_fixture()
      developer_fixture = developer_fixture()
      attrs = %{
        start_time: ~N[2025-08-11 10:30:00],
        end_time: ~N[2025-08-11 20:30:00],
        description: "some description",
        developer_id: developer_fixture.id,
        project_id: project_brief_fixture.id
      }

      changeset = TimeEntry.changeset(%TimeEntry{}, attrs)
      assert changeset.valid?
      assert changeset.changes.start_time == ~N[2025-08-11 10:30:00]
      assert changeset.changes.end_time == ~N[2025-08-11 20:30:00]
      assert changeset.changes.description == "some description"
      assert changeset.changes.developer_id == developer_fixture.id
      assert changeset.changes.project_id == project_brief_fixture.id
    end
  end
end
