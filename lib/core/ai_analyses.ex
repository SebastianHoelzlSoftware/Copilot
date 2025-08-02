defmodule CopilotApi.Core.AIAnalyses do
  @moduledoc """
  The AIAnalyses context.
  """

  import Ecto.Query, warn: false
  alias CopilotApi.Repo

  alias CopilotApi.Core.Data.AIAnalysis

  @doc """
  Returns the list of ai_analyses.

  ## Examples

      iex> list_ai_analyses()
      [%AIAnalysis{}, ...]

  """
  def list_ai_analyses do
    Repo.all(from a in AIAnalysis, preload: [:project_brief])
  end

  @doc """
  Gets a single ai_analysis.

  Raises `Ecto.NoResultsError` if the AI analysis does not exist.

  ## Examples

      iex> get_ai_analysis!(123)
      %AIAnalysis{}

      iex> get_ai_analysis!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ai_analysis!(id) do
    AIAnalysis
    |> Repo.get!(id)
    |> Repo.preload([:project_brief, :cost_estimate])
  end

  @doc """
  Creates an ai_analysis.

  ## Examples

      iex> create_ai_analysis(%{field: value})
      {:ok, %AIAnalysis{}}

      iex> create_ai_analysis(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ai_analysis(attrs \\ %{}) do
    %AIAnalysis{}
    |> AIAnalysis.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an ai_analysis.
  """
  def update_ai_analysis(%AIAnalysis{} = ai_analysis, attrs) do
    ai_analysis
    |> AIAnalysis.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an ai_analysis.
  """
  def delete_ai_analysis(%AIAnalysis{} = ai_analysis) do
    Repo.delete(ai_analysis)
  end
end
