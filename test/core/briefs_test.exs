defmodule CopilotApi.Core.BriefsTest do
  use CopilotApi.DataCase

  alias CopilotApi.Core.Briefs
  alias CopilotApi.Core.Data.ProjectBrief

  import CopilotApi.Core.Fixtures

  @invalid_attrs %{title: nil}

  describe "list_project_briefs/0" do
    test "returns all project_briefs" do
      project_brief = project_brief_fixture()
      [fetched_brief] = Briefs.list_project_briefs()

      assert fetched_brief.id == project_brief.id
      assert fetched_brief.customer
    end
  end

  describe "get_project_brief!/1" do
    test "returns the project_brief with given id" do
      project_brief = project_brief_fixture()
      ai_analysis = ai_analysis_fixture(%{project_brief: project_brief})

      fetched_brief = Briefs.get_project_brief!(project_brief.id)

      assert fetched_brief.id == project_brief.id
      assert fetched_brief.customer
      assert fetched_brief.ai_analysis.id == ai_analysis.id
    end

    test "raises if the Project brief does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Briefs.get_project_brief!(Ecto.UUID.generate()) end
    end
  end

  describe "create_project_brief/1" do
    test "with valid data creates a project_brief" do
      customer = customer_fixture()

      valid_attrs = %{
        title: "some title",
        summary: "some summary",
        customer_id: customer.id
      }

      assert {:ok, %ProjectBrief{} = project_brief} = Briefs.create_project_brief(valid_attrs)
      assert project_brief.title == "some title"
      assert project_brief.summary == "some summary"
      assert project_brief.customer_id == customer.id
    end

    test "with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Briefs.create_project_brief(@invalid_attrs)
    end

    test "with no arguments returns an error changeset" do
      # This test covers the default argument path of create_project_brief/1
      assert {:error, %Ecto.Changeset{}} = Briefs.create_project_brief()
    end
  end

  describe "update_project_brief/2" do
    test "with valid data updates the project_brief" do
      project_brief = project_brief_fixture()
      update_attrs = %{title: "new title", summary: "new summary"}

      assert {:ok, %ProjectBrief{} = updated_brief} =
               Briefs.update_project_brief(project_brief, update_attrs)

      assert updated_brief.title == "new title"
      assert updated_brief.summary == "new summary"
    end

    test "with invalid data returns an error changeset" do
      project_brief = project_brief_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Briefs.update_project_brief(project_brief, @invalid_attrs)

      assert Briefs.get_project_brief!(project_brief.id).title == project_brief.title
    end
  end

  describe "delete_project_brief/1" do
    test "deletes the project_brief" do
      project_brief = project_brief_fixture()
      assert {:ok, %ProjectBrief{}} = Briefs.delete_project_brief(project_brief)
      assert_raise Ecto.NoResultsError, fn -> Briefs.get_project_brief!(project_brief.id) end
    end
  end

  describe "change_project_brief/2" do
    test "returns a project_brief changeset" do
      brief = project_brief_fixture()
      assert %Ecto.Changeset{} = Briefs.change_project_brief(brief)
    end
  end

  describe "list_project_briefs_for_customer/1" do
    test "returns all briefs for a given customer" do
      customer = customer_fixture()
      brief1 = project_brief_fixture(%{customer: customer})
      brief2 = project_brief_fixture(%{customer: customer})
      # Create another brief for a different customer to ensure it's not returned
      project_brief_fixture()

      briefs = Briefs.list_project_briefs_for_customer(customer)

      assert length(briefs) == 2
      assert Enum.map(briefs, & &1.id) |> Enum.sort() == [brief1.id, brief2.id] |> Enum.sort()
      assert Enum.all?(briefs, &(&1.customer))
    end
  end
end
