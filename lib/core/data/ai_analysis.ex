defmodule CopilotApi.Core.Data.AIAnalysis do
  @moduledoc "Holds the results of an AI analysis of a project brief."

  alias CopilotApi.Core.Data.{BuildingBlock, ClarifyingQuestion, CostEstimate}

  defstruct [:suggested_blocks, :clarifying_questions, :cost_estimate, :identified_ambiguities]

  @type t() :: %__MODULE__{
          suggested_blocks: [BuildingBlock.t()],
          clarifying_questions: [ClarifyingQuestion.t()],
          cost_estimate: CostEstimate.t() | nil,
          identified_ambiguities: [String.t()]
        }

  def new(attrs) when is_map(attrs) do
    defaults = %{
      suggested_blocks: [],
      clarifying_questions: [],
      cost_estimate: nil,
      identified_ambiguities: []
    }

    attrs_with_defaults = Map.merge(defaults, attrs)

    with {:ok, blocks} <- new_list(attrs_with_defaults[:suggested_blocks], &BuildingBlock.new/1),
         {:ok, questions} <-
           new_list(attrs_with_defaults[:clarifying_questions], &ClarifyingQuestion.new/1),
         {:ok, estimate} <- new_cost_estimate(attrs_with_defaults[:cost_estimate]) do
      final_attrs = %{
        suggested_blocks: blocks,
        clarifying_questions: questions,
        cost_estimate: estimate,
        identified_ambiguities: attrs_with_defaults[:identified_ambiguities]
      }

      {:ok, struct(__MODULE__, final_attrs)}
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  defp new_cost_estimate(nil), do: {:ok, nil}
  defp new_cost_estimate(attrs) when is_map(attrs), do: CostEstimate.new(attrs)
  defp new_cost_estimate(_), do: {:error, :invalid_cost_estimate_attrs}

  defp new_list(items, fun) when is_list(items) do
    results = Enum.map(items, fun)

    if Enum.all?(results, &match?({:ok, _}, &1)) do
      {:ok, for({:ok, item} <- results, do: item)}
    else
      Enum.find(results, &match?({:error, _}, &1))
    end
  end

  defp new_list(_, _), do: {:error, :invalid_list_type}
end
