defmodule CopilotApi.Core.Data.Customer do
  @moduledoc """
  A struct representing a customer.
  """

  alias CopilotApi.Core.Data.Address
  alias CopilotApi.Core.Data.Contact
  alias CopilotApi.Core.Data.Name # Still alias Name as Contact also uses it

  defstruct [
    :id,
    name: %Name{},
    contact: %Contact{},
    address: %Address{},
  ]

  @enforce_keys [:id, :name, :contact, :address]

  @doc """
  Creates a new Customer struct.
  Expects `attrs` to contain `id` (string), `name` (map), `contact` (map), and `address` (map).
  Returns `{:ok, struct}` on success, `{:error, reason}` on validation failure.
  """
  def new(attrs) do
    unless is_map(attrs), do: {:error, :invalid_attributes_type}

    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))
    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      # Validate ID
      id = Map.get(attrs, :id)
      unless is_binary(id) and String.length(id) > 0 do
        {:error, :invalid_id_format}
      else
        with {:ok, name_struct} <- Name.new(Map.get(attrs, :name)),
             {:ok, contact_struct} <- Contact.new(Map.get(attrs, :contact)),
             {:ok, address_struct} <- Address.new(Map.get(attrs, :address)) do
          {:ok, %__MODULE__{
            id: id,
            name: name_struct,
            contact: contact_struct,
            address: address_struct
          }}
        else
          {:error, reason} ->
            {:error, reason}
        end
      end
    end
  end

  @type t() :: %__MODULE__{
    id: String.t(),
    name: Name.t(),
    contact: Contact.t(),
    address: Address.t()
  }
end
