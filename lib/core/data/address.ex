defmodule CopilotApi.Core.Data.Address do
  @moduledoc """
  A struct representing a physical address.
  """

  defstruct [
    :street,
    :street_additional,
    :city,
    :postal_code,
    :country
  ]

  @enforce_keys [:street, :city, :postal_code, :country]

  @doc """
  Creates a new Address struct.
  Returns `{:ok, struct}` on success, `{:error, reason}` on validation failure.
  """
  def new(attrs) when is_map(attrs) do
    # Check for enforced keys
    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))

    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      # Filter attributes to only include those defined in the struct
      defined_keys = Map.keys(__struct__())
      filtered_attrs = Map.take(attrs, defined_keys)
      {:ok, struct(__MODULE__, filtered_attrs)}
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  @doc """
  Returns a formatted string of the address.
  """
  def format(%__MODULE__{} = address) do
    [
      address.street,
      address.street_additional,
      address.city,
      address.postal_code,
      address.country
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  @type t() :: %__MODULE__{
    street: String.t(),
    street_additional: String.t() | nil,
    city: String.t(),
    postal_code: String.t(),
    country: String.t()
  }
end
