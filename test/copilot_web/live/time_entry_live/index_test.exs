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

    test "shows a message if the developer has no projects", %{} do
      # Create a developer with no projects
      developer = Fixtures.developer_fixture()

      conn =
        Phoenix.ConnTest.build_conn()
        |> Phoenix.ConnTest.init_test_session(%{current_user_id: developer.id})

      {:ok, view, html} = live(conn, ~p"/time-tracking")
      assert html =~ "No Projects Assigned"
      # When there are no projects, the entire timer control block is hidden.
      refute has_element?(view, "button", "Start")
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

      # Re-mount the LiveView to get the updated state
      {:ok, view, _html} = live(conn, ~p"/time-tracking")

      refute render(view) =~ time_entry.description
      refute time_entry in TimeTracking.list_time_entries_for_developer(developer)
    end

    test "re-joins a running timer", %{conn: conn} do
      # 1. Initial mount and start the timer
      {:ok, view, _html} = live(conn, ~p"/time-tracking")

      view
      |> element("form")
      |> render_change(%{"description" => "Testing re-join"})

      view
      |> element("form")
      |> render_submit()

      assert has_element?(view, "button[disabled]", "Start")

      # 2. Disconnect the LiveView, simulating the user navigating away
      # We manually stop the LiveView process to simulate a disconnect.
      Process.unlink(view.pid)
      Process.exit(view.pid, :normal)

      # 3. Wait for a couple of seconds
      Process.sleep(2100)

      # 4. Reconnect a new LiveView for the same user
      {:ok, new_view, new_html} = live(conn, ~p"/time-tracking")

      # 5. Assert that the new view reflects the running timer's state
      assert new_html =~ "Testing re-join"
      assert has_element?(new_view, "button[disabled]", "Start")
      refute has_element?(new_view, "button[disabled]", "Stop")
      assert new_html =~ ~r/00:00:0[2-9]/
    end

    test "updates the timer in real-time via PubSub", %{conn: conn, developer: developer} do
      # 1. Connect two LiveViews for the same user
      # Subscribe the test process to the user's timer topic to listen for events.
      Phoenix.PubSub.subscribe(Copilot.PubSub, "user_timers:#{developer.id}")

      {:ok, view_a, _html_a} = live(conn, ~p"/time-tracking")
      {:ok, view_b, html_b} = live(conn, ~p"/time-tracking")

      # 2. Assert initial state for the second view
      assert html_b =~ "00:00:00"
      refute has_element?(view_b, "button[disabled]", "Start")

      # 3. Start the timer in the first view
      view_a
      |> element("form")
      |> render_submit()

      # 4. Wait for a tick and assert the second view was updated
      Process.sleep(1100)
      assert render(view_b) =~ ~r/00:00:0[1-9]/
      assert has_element?(view_b, "button[disabled]", "Start")

      # 5. Stop the timer in the first view
      render_click(view_a, "stop_timer")

      # Deterministically wait for the "stopped" event to be broadcast.
      # This ensures that view_b has received and processed the message
      # before we make our assertions, avoiding a race condition.
      assert_receive %{event: "stopped", payload: %{time_entry: time_entry}}

      # 6. Assert the second view was stopped and the new entry is visible.
      # We use a helper to wait for the async update to appear in the DOM.
      assert_eventually(fn ->
        assert has_element?(view_b, "##{time_entry.id} td:contains(\"#{developer.name}\")")
      end)
    end
  end

  defp assert_eventually(check_fun, retries \\ 10, delay \\ 10) do
    try do
      check_fun.()
    rescue
      ExUnit.AssertionError ->
        if retries > 0, do: :timer.sleep(delay)
        if retries > 0, do: assert_eventually(check_fun, retries - 1, delay)
    end
  end
end
