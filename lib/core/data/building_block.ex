defmodule CopilotApi.Core.Data.BuildingBlock do
  @moduledoc "Represents a suggested software building block."

  defstruct [:name, :description]

  @type t() :: %__MODULE__{
          name: String.t(),
          description: String.t() | nil
        }

  def new(attrs) when is_map(attrs) do
    if Map.get(attrs, :name) |> is_binary() and Map.get(attrs, :name) != "" do
      filtered_attrs = Map.take(attrs, [:name, :description])
      {:ok, struct(__MODULE__, filtered_attrs)}
    else
      {:error, :missing_or_invalid_name}
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}
end
