defmodule CopilotApi.Core.Data.ProjectBrief do
  @moduledoc "Represents a customer's project brief."

  alias CopilotApi.Core.Data.AIAnalysis

  defstruct [:id, :customer_id, :developer_id, :title, :summary, :status, :ai_analysis]

  @enforce_keys [:id, :customer_id, :title, :summary]

  @type t() :: %__MODULE__{
          id: String.t(),
          customer_id: String.t(),
          developer_id: String.t() | nil,
          title: String.t(),
          summary: String.t(),
          status: :new | :under_review | :accepted | :declined,
          ai_analysis: AIAnalysis.t() | nil
        }

  def new(attrs) when is_map(attrs) do
    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))

    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      with :ok <- validate_id(attrs[:id]),
           :ok <- validate_customer_id(attrs[:customer_id]),
           :ok <- validate_developer_id(Map.get(attrs, :developer_id)),
           :ok <- validate_title(attrs[:title]),
           :ok <- validate_summary(attrs[:summary]),
           {:ok, ai_analysis} <- new_ai_analysis(Map.get(attrs, :ai_analysis)) do
        defaults = %{status: :new, ai_analysis: ai_analysis}

        final_attrs =
          attrs
          |> Map.merge(defaults)
          |> Map.take(Map.keys(__struct__()))

        {:ok, struct(__MODULE__, final_attrs)}
      end
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  defp validate_id(id) when is_binary(id) and id != "", do: :ok
  defp validate_id(_), do: {:error, :invalid_id_format}

  defp validate_customer_id(id) when is_binary(id) and id != "", do: :ok
  defp validate_customer_id(_), do: {:error, :invalid_customer_id_format}

  defp validate_developer_id(nil), do: :ok
  defp validate_developer_id(id) when is_binary(id) and id != "", do: :ok
  defp validate_developer_id(_), do: {:error, :invalid_developer_id_format}

  defp validate_title(title) when is_binary(title) and title != "", do: :ok
  defp validate_title(_), do: {:error, :invalid_title}

  defp validate_summary(summary) when is_binary(summary) and summary != "", do: :ok
  defp validate_summary(_), do: {:error, :invalid_summary}

  defp new_ai_analysis(nil), do: {:ok, nil}
  defp new_ai_analysis(attrs) when is_map(attrs), do: AIAnalysis.new(attrs)
  defp new_ai_analysis(_), do: {:error, :invalid_ai_analysis_attrs}
end
