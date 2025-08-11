defmodule Copilot.Core.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Copilot.Core` context.
  """

  alias Copilot.Repo
  alias Copilot.Core.Data.Customer
  alias Copilot.Core.Data.User
  alias Copilot.Core.Users
  alias Copilot.Core.Contacts
  alias Copilot.Core.Briefs
  alias Copilot.Core.AIAnalyses
  alias Copilot.Core.Data.CostEstimate
  alias Copilot.Core.Data.TimeEntry

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
    |> Repo.preload(:contacts)
  end

  def developer_fixture(attrs \\ %{}) do
    unique_int = System.unique_integer([:positive])
    %User{}
    |> User.changeset(
      Enum.into(attrs, %{
        email: "developer-#{unique_int}@example.com",
        name: "Dev User-#{unique_int}",
        provider: "google",
        provider_id: "dev-#{unique_int}",
        roles: ["developer"]
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
    |> Repo.preload(:customer)
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
    |> Repo.preload(:project_brief)
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

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    default_attrs = %{
      email: "user-#{System.unique_integer([:positive])}@example.com",
      name: %{first_name: "Test", last_name: "User"},
      provider: "google",
      provider_id: "user-#{System.unique_integer([:positive])}",
      roles: ["customer"]
    }

    {:ok, user} =
      attrs
      |> Enum.into(default_attrs)
      |> Users.create_user_for_registration()

    user
  end

  @doc """
  Generate a time_entry.
  """
  def time_entry_fixture(attrs \\ %{}) do
    developer = Map.get(attrs, :developer) || developer_fixture()
    project = Map.get(attrs, :project) || project_brief_fixture()

    default_attrs = %{
      start_time: ~N[2025-08-11 10:30:00],
      end_time: ~N[2025-08-11 12:30:00],
      description: "some description",
      developer_id: developer.id,
      project_id: project.id
    }

    %TimeEntry{}
    |> TimeEntry.changeset(Enum.into(attrs, default_attrs))
    |> Repo.insert!()
  end
end
