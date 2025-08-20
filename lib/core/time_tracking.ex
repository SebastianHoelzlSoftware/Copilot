defmodule Copilot.Core.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias Copilot.Repo

  alias Copilot.Core.Data.TimeEntry

  @doc """
  Returns the list of time_entries.

  ## Examples

      iex> list_time_entries()
      [%TimeEntry{}, ...]

  """
  def list_time_entries(params \\ %{}) do
    TimeEntry
    |> maybe_filter_by_developer_id(params["developer_id"])
    |> maybe_filter_by_project_brief_id(params["project_brief_id"])
    |> maybe_filter_by_start_date(params["start_date"])
    |> maybe_filter_by_end_date(params["end_date"])
    |> Repo.all()
  end

  defp maybe_filter_by_developer_id(query, nil), do: query
  defp maybe_filter_by_developer_id(query, developer_id) do
    from q in query, where: q.developer_id == ^developer_id
  end

  defp maybe_filter_by_project_brief_id(query, nil), do: query
  defp maybe_filter_by_project_brief_id(query, project_brief_id) do
    from q in query, where: q.project_brief_id == ^project_brief_id
  end

  defp maybe_filter_by_start_date(query, nil), do: query
  defp maybe_filter_by_start_date(query, start_date) do
    from q in query, where: q.start_time >= ^start_date
  end

  defp maybe_filter_by_end_date(query, nil), do: query
  defp maybe_filter_by_end_date(query, end_date) do
    from q in query, where: q.end_time <= ^end_date
  end

  @doc """
  Returns the list of time_entries for a given project.

  ## Examples

      iex> list_time_entries_for_project(project)
      [%TimeEntry{}, ...]

  """
  def list_time_entries_for_project(project) do
    Repo.all(
      from t in TimeEntry,
        where: t.project_id == ^project.id
    )
  end

  @doc """
  Gets a single time_entry.

  Raises `Ecto.NoResultsError` if the Time entry does not exist.

  ## Examples

      iex> get_time_entry!(123)
      %TimeEntry{}

      iex> get_time_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_time_entry!(id), do: Repo.get!(TimeEntry, id)

  @doc """
  Creates a time_entry.

  ## Examples

      iex> create_time_entry(%{field: value})
      {:ok, %TimeEntry{}}

      iex> create_time_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_time_entry(attrs \\ %{}) do
    %TimeEntry{}
    |> TimeEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a time_entry.

  ## Examples

      iex> update_time_entry(time_entry, %{field: new_value})
      {:ok, %TimeEntry{}}

      iex> update_time_entry(time_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_time_entry(%TimeEntry{} = time_entry, attrs) do
    time_entry
    |> TimeEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a time_entry.
  """
  def delete_time_entry(%TimeEntry{} = time_entry) do
    Repo.delete(time_entry)
  end
end
