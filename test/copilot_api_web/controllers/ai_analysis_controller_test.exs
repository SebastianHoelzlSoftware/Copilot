defmodule CopilotApiWeb.AIAnalysisControllerTest do
  use CopilotApiWeb.ConnCase

  import CopilotApi.Core.Fixtures

  @create_attrs %{summary: "new analysis summary"}
  @update_attrs %{summary: "updated analysis summary"}
  @invalid_attrs %{summary: nil}

  defp as_customer(conn, customer) do
    conn
    |> put_req_header("x-user-role", "customer")
    |> put_req_header("x-customer-id", customer.id)
  end

  defp as_developer(conn) do
    conn
    |> put_req_header("x-user-role", "developer")
  end

  setup %{conn: conn} do
    owner_customer = customer_fixture()
    brief = project_brief_fixture(%{customer: owner_customer})
    analysis = ai_analysis_fixture(%{project_brief: brief})
    other_customer = customer_fixture()

    conn = as_customer(conn, owner_customer)

    {:ok, conn: conn, analysis: analysis, brief: brief, other_customer: other_customer}
  end

  describe "index" do
    test "is forbidden for a customer", %{conn: conn} do
      conn = get(conn, ~p"/api/ai_analyses")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "lists all analyses for a developer", %{conn: conn, analysis: analysis} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/ai_analyses")
      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == analysis.id))
    end
  end

  describe "create" do
    test "is forbidden for a customer", %{conn: conn, brief: brief} do
      create_attrs = Map.put(@create_attrs, "project_brief_id", brief.id)
      conn = post(conn, ~p"/api/ai_analyses", %{"ai_analysis" => create_attrs})

      assert json_response(conn, 403)["error"]["message"] ==
               "Only developers can create an AI analysis"
    end

    test "creates an analysis for a developer", %{conn: conn} do
      # Create a new brief that doesn't have an analysis yet for this test.
      brief = project_brief_fixture()
      create_attrs = Map.put(@create_attrs, "project_brief_id", brief.id)
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/ai_analyses", %{"ai_analysis" => create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      analysis = CopilotApi.Core.AIAnalyses.get_ai_analysis!(id)
      assert analysis.summary == "new analysis summary"
      assert analysis.project_brief_id == brief.id
    end

    test "does not create analysis with invalid data", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/ai_analyses", %{"ai_analysis" => @invalid_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 400 when ai_analysis params are missing", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/ai_analyses", %{})

      assert json_response(conn, 400)
    end
  end

  describe "show" do
    test "shows analysis for owner of the brief", %{conn: conn, analysis: analysis} do
      conn = get(conn, ~p"/api/ai_analyses/#{analysis}")
      assert json_response(conn, 200)["data"]["id"] == analysis.id
    end

    test "shows analysis for developer", %{conn: conn, analysis: analysis} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/ai_analyses/#{analysis}")
      assert json_response(conn, 200)["data"]["id"] == analysis.id
    end

    test "is forbidden for other customer", %{
      conn: conn,
      analysis: analysis,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = get(conn, ~p"/api/ai_analyses/#{analysis}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end
  end

  describe "update" do
    test "is forbidden for owner", %{conn: conn, analysis: analysis} do
      conn = put(conn, ~p"/api/ai_analyses/#{analysis}", %{"ai_analysis" => @update_attrs})

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "updates analysis for developer", %{conn: conn, analysis: analysis} do
      conn = as_developer(conn)
      conn = put(conn, ~p"/api/ai_analyses/#{analysis}", %{"ai_analysis" => @update_attrs})
      assert json_response(conn, 200)["data"]["summary"] == "updated analysis summary"
    end

    test "returns 400 when ai_analysis params are missing", %{conn: conn, analysis: analysis} do
      conn = as_developer(conn)
      conn = put(conn, ~p"/api/ai_analyses/#{analysis}", %{})

      assert json_response(conn, 400)
    end
  end

  describe "delete" do
    test "is forbidden for owner", %{conn: conn, analysis: analysis} do
      conn = delete(conn, ~p"/api/ai_analyses/#{analysis}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "deletes analysis for developer", %{conn: conn, analysis: analysis} do
      conn = as_developer(conn)
      conn = delete(conn, ~p"/api/ai_analyses/#{analysis}")
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        CopilotApi.Core.AIAnalyses.get_ai_analysis!(analysis.id)
      end
    end
  end
end
