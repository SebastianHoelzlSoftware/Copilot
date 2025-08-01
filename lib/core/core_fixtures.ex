defmodule CopilotApi.Core.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CopilotApi.Core` context.
  """

  alias CopilotApi.Repo
  alias CopilotApi.Core.Data.Customer
  alias CopilotApi.Core.Contacts
  alias CopilotApi.Core.Briefs
  alias CopilotApi.Core.AIAnalyses
  alias CopilotApi.Core.Data.CostEstimate


  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(
      Enum.into(attrs, %{
        name: %{company_name: "Beautiful Comp"}
      })
    )
    |> Repo.insert!()
  end

  @doc """
  Generate a project_brief.
  """
  def project_brief_fixture(attrs \\ %{}) do
    customer = Map.get(attrs, :customer) || customer_fixture()

    {:ok, project_brief} =
      attrs
      |> Enum.into(%{
        customer_id: customer.id,
        title: "some title",
        summary: "some summary"
      })
      |> Briefs.create_project_brief()

    project_brief
    |> Repo.preload(:customer)
  end

    @doc """
  Generate a cost_estimate.
  """
  def cost_estimate_fixture(attrs \\ %{}) do
    customer = Map.get(attrs, :customer) || customer_fixture()

    %CostEstimate{}
    |> CostEstimate.changeset(
      Enum.into(attrs, %{
        amount: "120.5",
        currency: "USD",
        customer_id: customer.id
      })
    )
    |> Repo.insert!()
  end

  @doc """
  Generate an ai_analysis.
  """
  def ai_analysis_fixture(attrs \\ %{}) do
    project_brief = Map.get(attrs, :project_brief) || project_brief_fixture()

    {:ok, ai_analysis} =
      attrs
      |> Enum.into(%{project_brief_id: project_brief.id, summary: "some summary"})
      |> AIAnalyses.create_ai_analysis()

    ai_analysis
  end

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    customer = Map.get(attrs, :customer) || customer_fixture()

    valid_attrs = %{
      customer_id: customer.id,
      name: %{first_name: "John", last_name: "Doe"},
      email: %{address: "john.doe-#{System.unique_integer([:positive])}@example.com"}
    }

    {:ok, contact} =
      attrs
      |> Enum.into(valid_attrs)
      |> Contacts.create_contact()

    contact
  end
end
