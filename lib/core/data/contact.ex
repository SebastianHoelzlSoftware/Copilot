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
  def new(attrs) when is_map(attrs) do
    missing_keys = Enum.filter(@enforce_keys, &(!Map.has_key?(attrs, &1)))

    if Enum.any?(missing_keys) do
      {:error, {:missing_required_fields, missing_keys}}
    else
      with {:ok, name} <- Name.new(attrs.name),
           {:ok, email} <- Email.new(attrs.email),
           {:ok, address} <- Address.new(attrs.address) do
        {:ok, struct(__MODULE__, name: name, email: email, address: address)}
      end
    end
  end

  def new(_), do: {:error, :invalid_attributes_type}

  @type t() :: %__MODULE__{
    name: Name.t(),
    email: Email.t(),
    address: Address.t()
  }
end
