defmodule CopilotApi.Core.Data.Name do
  @moduledoc """
  A struct representing a manifold of names.
  """

  defstruct [
    # Default to nil
    company_name: nil,
    # Default to nil
    first_name: nil,
    # Default to nil
    last_name: nil
  ]

  # Assuming name fields are optional. If any are required, add them to @enforce_keys.
  # @enforce_keys [:first_name, :last_name] # Example if first/last are always required

  @doc """
  Creates a new Name struct.
  Expects `attrs` to be a map of name attributes.
  Returns `{:ok, struct}` on success, `{:error, reason}` on validation failure.
  """
  def new(attrs) when is_map(attrs) do
    # If you had @enforce_keys, you would check them here:
    # missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))
    # if Enum.any?(missing_keys), do: {:error, {:missing_required_fields, missing_keys}}

    # Filter attributes to only include those defined in the struct
    defined_keys = Map.keys(__struct__())
    filtered_attrs = Map.take(attrs, defined_keys)

    # Basic type validation for provided attributes
    with :ok <- validate_attribute_types(filtered_attrs) do
      name_struct = struct(__MODULE__, filtered_attrs)
      validate_name_fields(name_struct)
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  defp validate_name_fields(%__MODULE__{} = name_struct) do
    first = name_struct.first_name
    last = name_struct.last_name
    company = name_struct.company_name

    has_person_name = is_binary(first) and first != "" and is_binary(last) and last != ""
    has_company_name = is_binary(company) and company != ""

    if has_person_name or has_company_name do
      {:ok, name_struct}
    else
      {:error, :missing_name_or_company}
    end
  end

  defp validate_attribute_types(attrs) do
    Enum.reduce_while(attrs, :ok, fn {key, value}, _acc ->
      # nil is a valid value for all fields
      if is_nil(value) or is_binary(value) do
        {:cont, :ok}
      else
        {:halt, {:error, {:"invalid_#{key}_type", value}}}
      end
    end)
  end

  @type t() :: %__MODULE__{
          company_name: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil
        }
end
