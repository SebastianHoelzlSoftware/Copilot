defmodule CopilotApi.Core.Data.CostEstimate do
  @moduledoc "Represents a preliminary cost estimate."

  defstruct [:amount, :currency, :details]

  @enforce_keys [:amount, :currency]

  @type t() :: %__MODULE__{
    amount: number(),
    currency: String.t(),
    details: String.t() | nil
  }

  def new(attrs) when is_map(attrs) do
    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))

    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      with :ok <- validate_amount(attrs[:amount]),
           :ok <- validate_currency(attrs[:currency]) do
        filtered_attrs = Map.take(attrs, [:amount, :currency, :details])
        {:ok, struct(__MODULE__, filtered_attrs)}
      end
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  defp validate_amount(amount) when is_number(amount), do: :ok
  defp validate_amount(_), do: {:error, :invalid_amount}

  defp validate_currency(currency) when is_binary(currency) and currency != "", do: :ok
  defp validate_currency(_), do: {:error, :invalid_currency}
end
