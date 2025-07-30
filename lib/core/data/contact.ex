defmodule CopilotApi.Core.Data.Contact do
  @moduledoc """
  A struct representing a customer contact.
  """

  alias CopilotApi.Core.Data.Name
  alias CopilotApi.Core.Data.Email
  alias CopilotApi.Core.Data.Address

  defstruct [
    name: %Name{},
    email: %Email{},
    address: %Address{}
  ]

  @enforce_keys [:name, :email, :address]

  @doc """
  Creates a new contact struct.
  Expects `attrs` to contain `name` as a map of name attributes and `email` as an email string.
  Returns `{:ok, struct}` on success, `{:error, reason}` on validation failure.
  """
  def new(attrs) do
    unless is_map(attrs), do: {:error, :invalid_attributes_type}

    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))
    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      with {:ok, name_struct} <- Name.new(Map.get(attrs, :name)),
          {:ok, address_struct} <- Address.new(Map.get(attrs, :address)),
           {:ok, email_struct} <- Email.new(Map.get(attrs, :email)) do
        # Filter attributes for Contact's own fields (if any, excluding nested structs)
        # In this case, Contact only has nested structs, so it's simpler
        {:ok, %__MODULE__{name: name_struct, email: email_struct, address: address_struct}}
      else
        {:error, reason} -> {:error, reason}
      end
    end
  end

  @type t() :: %__MODULE__{
    name: Name.t(),
    email: Email.t(),
    address: Address.t()
  }
end
