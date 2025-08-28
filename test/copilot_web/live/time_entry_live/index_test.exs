defmodule CopilotWeb.Live.TimeEntryLive.IndexTest do
  use CopilotWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Copilot.Core.Fixtures
  alias Copilot.Core.TimeTracking

  setup do
    customer = Fixtures.customer_fixture()
    developer = Fixtures.developer_fixture(%{customer_id: customer.id})
    project = Fixtures.project_brief_fixture(%{customer: customer})

    conn = 
      Phoenix.ConnTest.build_conn()
      |> Phoenix.ConnTest.init_test_session(%{current_user_id: developer.id})

    {:ok, conn: conn, developer: developer, project: project}
  end

  describe "Time Tracking LiveView" do
    test "renders the time tracking page", %{conn: conn, project: project} do
      {:ok, view, html} = live(conn, ~p"/time-tracking")

      assert html =~ "Time Tracking"
      assert html =~ project.title
      assert html =~ "Start"
      assert html =~ "Stop"
      assert has_element?(view, "button[disabled]", "Stop")
      refute has_element?(view, "button[disabled]", "Start")
    end

    test "starts and stops the timer", %{conn: conn, developer: developer, project: project} do
      {:ok, view, _html} = live(conn, ~p"/time-tracking")

      # Start the timer
      view
      |> element("form")
      |> render_change(%{"description" => "Working on a new feature"})

      view
      |> element("form")
      |> render_submit()

      html = render(view)
      assert html =~ "00:00:00"
      assert has_element?(view, "button[disabled]", "Start")
      refute has_element?(view, "button[disabled]", "Stop")

      Process.sleep(1100)

      # Stop the timer
      view |> render_click("stop_timer")

      html = render(view)
      assert html =~ "00:00:00"
      assert has_element?(view, "button[disabled]", "Stop")
      refute has_element?(view, "button[disabled]", "Start")

      # Check if the time entry was created
      [time_entry] = TimeTracking.list_time_entries_for_developer(developer)
      assert time_entry.description == "Working on a new feature"
      assert time_entry.project_id == project.id
    end

    test "deletes a time entry", %{conn: conn, developer: developer, project: project} do
      time_entry = Fixtures.time_entry_fixture(%{developer: developer, project: project})
      {:ok, view, _html} = live(conn, ~p"/time-tracking")

      assert render(view) =~ time_entry.description

      view
      |> element(~s|[phx-value-id="#{time_entry.id}"]|)
      |> render_click()

      refute render(view) =~ time_entry.description
      refute time_entry in TimeTracking.list_time_entries_for_developer(developer)
    end
  end
end
