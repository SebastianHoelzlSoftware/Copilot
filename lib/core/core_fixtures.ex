defmodule CopilotApi.Core.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CopilotApi.Core` context.
  """

  alias CopilotApi.Repo
  alias CopilotApi.Core.Data.Customer
  alias CopilotApi.Core.Briefs

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(
      Enum.into(attrs, %{
        name: %{company_name: "Beautiful Comp"},
        email: "user-#{System.unique_integer([:positive])}@example.com"
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
  end
end
