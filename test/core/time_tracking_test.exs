defmodule Copilot.Core.TimeTrackingTest do
  use Copilot.DataCase

  alias Copilot.Core.TimeTracking
  alias Copilot.Core.Data.TimeEntry

  import Copilot.Core.Fixtures

  describe "time_entries" do
    @invalid_attrs %{start_time: nil, end_time: nil, developer_id: nil, project_id: nil}

    test "list_time_entries/0 returns all time_entries" do
      time_entry = time_entry_fixture()
      assert TimeTracking.list_time_entries() == [time_entry]
    end

    test "list_time_entries_for_project/1 returns time entries for a specific project" do
      project1 = project_brief_fixture()
      project2 = project_brief_fixture()
      developer = developer_fixture()

      time_entry1 = time_entry_fixture(%{project: project1, developer: developer})
      _time_entry2 = time_entry_fixture(%{project: project2, developer: developer})

      assert TimeTracking.list_time_entries_for_project(project1) == [time_entry1]
    end

    test "list_time_entries_for_developer/1 returns time entries for a specific developer" do
      developer1 = developer_fixture()
      developer2 = developer_fixture(%{email: "dev2@example.com"})
      project = project_brief_fixture()

      time_entry1 = time_entry_fixture(%{developer: developer1, project: project})
      _time_entry2 = time_entry_fixture(%{developer: developer2, project: project})

      [result_entry] = TimeTracking.list_time_entries_for_developer(developer1)
      assert result_entry.id == time_entry1.id
      assert result_entry.project.id == project.id
    end

    test "get_time_entry!/1 returns the time_entry with given id" do
      time_entry = time_entry_fixture()
      assert TimeTracking.get_time_entry!(time_entry.id) == time_entry
    end

    test "create_time_entry/1 with valid data creates a time_entry" do
      developer = developer_fixture()
      project = project_brief_fixture()

      valid_attrs = %{
        start_time: ~N[2025-08-11 10:30:00],
        end_time: ~N[2025-08-11 12:30:00],
        description: "some description",
        developer_id: developer.id,
        project_id: project.id
      }

      assert {:ok, %TimeEntry{} = time_entry} = TimeTracking.create_time_entry(valid_attrs)
      assert time_entry.start_time == ~N[2025-08-11 10:30:00]
      assert time_entry.end_time == ~N[2025-08-11 12:30:00]
      assert time_entry.description == "some description"
    end

    test "create_time_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_time_entry(@invalid_attrs)
    end

    test "update_time_entry/2 with valid data updates the time_entry" do
      time_entry = time_entry_fixture()

      update_attrs = %{
        description: "new description"
      }

      assert {:ok, %TimeEntry{} = time_entry} =
               TimeTracking.update_time_entry(time_entry, update_attrs)

      assert time_entry.description == "new description"
    end

    test "update_time_entry/2 with invalid data returns error changeset" do
      time_entry = time_entry_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TimeTracking.update_time_entry(time_entry, @invalid_attrs)

      assert time_entry == TimeTracking.get_time_entry!(time_entry.id)
    end

    test "delete_time_entry/1 deletes the time_entry" do
      time_entry = time_entry_fixture()
      assert {:ok, %TimeEntry{}} = TimeTracking.delete_time_entry(time_entry)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_time_entry!(time_entry.id) end
    end

    test "change_time_entry/1 returns a time_entry changeset" do
      time_entry = time_entry_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_time_entry(time_entry)
    end
  end
end
