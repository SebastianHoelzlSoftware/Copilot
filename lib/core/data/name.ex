defmodule CopilotApi.Core.Data.Name do
  @moduledoc "An embedded schema for a person's or company's name."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :company_name, :string
    field :first_name, :string
    field :last_name, :string
  end

  @doc """
  Builds a changeset for a Name.
  """
  def changeset(name, attrs) do
    name
    |> cast(attrs, [:company_name, :first_name, :last_name])
    |> validate_required_name_fields()
  end

  defp validate_required_name_fields(changeset) do
    first_name = get_field(changeset, :first_name)
    last_name = get_field(changeset, :last_name)
    company_name = get_field(changeset, :company_name)

    has_person_name = is_binary(first_name) and first_name != "" and is_binary(last_name) and last_name != ""
    has_company_name = is_binary(company_name) and company_name != ""

    if has_person_name or has_company_name do
      changeset
    else
      # If a person's name is partially provided, it's an error.
      if (is_binary(first_name) and first_name != "") or (is_binary(last_name) and last_name != "") do
        add_error(changeset, :base, "must provide both first and last name for a person")
      else
        add_error(changeset, :base, "must provide either a company name or a person's full name")
      end
    end
  end

  @type t() :: %__MODULE__{
          company_name: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil
        }
end
