defmodule CopilotApi.Core.Data.Customer do
  @moduledoc """
  A struct representing a customer, which includes an ID, name, contact, and address.
  """

  alias CopilotApi.Core.Data.{Address, Contact, Name}

  defstruct [:id, :name, :contact, :address]

  @enforce_keys [:id, :name, :contact, :address]

  @type t() :: %__MODULE__{
    id: String.t(),
    name: Name.t(),
    contact: Contact.t(),
    address: Address.t()
  }

  def new(attrs) when is_map(attrs) do
    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))

    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      with :ok <- validate_id(attrs[:id]),
           {:ok, name} <- Name.new(attrs[:name]),
           {:ok, contact} <- Contact.new(attrs[:contact]),
           {:ok, address} <- Address.new(attrs[:address]) do
        {:ok, struct(__MODULE__, id: attrs[:id], name: name, contact: contact, address: address)}
      end
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  defp validate_id(id) when is_binary(id) and id != "", do: :ok
  defp validate_id(_), do: {:error, :invalid_id_format}
end
