defmodule CopilotApi.Core.Data.Email do
  @moduledoc "Represents a validated email address."
  defstruct [:address]

  @type t() :: %__MODULE__{address: String.t()}

  @doc """
  Attempts to create a new Email struct.
  Returns `{:ok, struct}` on success, `{:error, reason}` on failure.
  """
  def new(email_string) when is_binary(email_string) do
    # Basic regex for format validation.
    # For robust production use, consider adding Hex packages for email validation.
    if Regex.match?(~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/, email_string) do
      {:ok, %__MODULE__{address: email_string}}
    else
      {:error, :invalid_email_format}
    end
  end

  # Handle cases where input is not a binary (e.g., nil, number, map)
  def new(_), do: {:error, :invalid_email_type}

  @doc "Returns the email address as a string."
  def to_string(%__MODULE__{address: address}), do: address

end
