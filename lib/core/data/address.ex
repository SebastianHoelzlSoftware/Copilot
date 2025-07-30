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
  def new(attrs) do
    # Ensure attrs is a map
    unless is_map(attrs), do: {:error, :invalid_attributes_type}

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

  @doc """
  Returns a formatted string of the address.
  """
  def format(%__MODULE__{} = address) do
    formatted_address = "#{address.street}"
    formatted_address = if address.street_additional, do: formatted_address <> "\n#{address.street_additional}", else: formatted_address
    formatted_address <> "\n#{address.city}\n#{address.postal_code}\n#{address.country}"
  end

  @type t() :: %__MODULE__{
    street: String.t(),
    street_additional: String.t() | nil,
    city: String.t(),
    postal_code: String.t(),
    country: String.t()
  }
end
