defmodule Copilot.TimeTracker do
  @moduledoc """
  The TimeTracker context.
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
  def list_time_entries do
    Repo.all(TimeEntry)
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
