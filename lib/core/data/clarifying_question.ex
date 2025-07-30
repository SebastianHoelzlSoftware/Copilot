defmodule CopilotApi.Core.Data.ClarifyingQuestion do
  @moduledoc "Represents a question to clarify project requirements."

  defstruct [:question, :answer]

  @type t() :: %__MODULE__{
          question: String.t(),
          answer: String.t() | nil
        }

  def new(attrs) when is_map(attrs) do
    if Map.get(attrs, :question) |> is_binary() and Map.get(attrs, :question) != "" do
      filtered_attrs = Map.take(attrs, [:question, :answer])
      {:ok, struct(__MODULE__, filtered_attrs)}
    else
      {:error, :missing_or_invalid_question}
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}
end
