defmodule CopilotApi.Core.Briefs do
  @moduledoc """
  The Briefs context.
  """

  import Ecto.Query, warn: false
  alias CopilotApi.Repo

  alias CopilotApi.Core.Data.ProjectBrief

  @doc """
  Returns the list of project_briefs.

  ## Examples

      iex> list_project_briefs()
      [%ProjectBrief{}, ...]

  """
  def list_project_briefs do
    Repo.all(from p in ProjectBrief, preload: [:customer])
  end

  @doc """
  Returns the list of project_briefs for a given customer.
  """
  def list_project_briefs_for_customer(customer) do
    ProjectBrief
    |> where([p], p.customer_id == ^customer.id)
    |> Repo.all()
    |> Repo.preload(:customer)
  end

  @doc """
  Gets a single project_brief.

  Raises `Ecto.NoResultsError` if the Project brief does not exist.

  ## Examples

      iex> get_project_brief!(123)
      %ProjectBrief{}

      iex> get_project_brief!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_brief!(id) do
    ProjectBrief
    |> Repo.get!(id)
    |> Repo.preload([:customer, ai_analysis: [:cost_estimate]])
  end

  @doc """
  Creates a project_brief.

  ## Examples

      iex> create_project_brief(%{field: value})
      {:ok, %ProjectBrief{}}

      iex> create_project_brief(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_brief(attrs \\ %{}) do
    %ProjectBrief{}
    |> ProjectBrief.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_brief.
  """
  def update_project_brief(%ProjectBrief{} = project_brief, attrs) do
    project_brief
    |> ProjectBrief.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project_brief.
  """
  def delete_project_brief(%ProjectBrief{} = project_brief) do
    Repo.delete(project_brief)
  end
end
