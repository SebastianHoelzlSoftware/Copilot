defmodule CopilotApiWeb.ChangesetJSON do
  @moduledoc """
  Renders a changeset into a JSON response.
  """

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp translate_error({msg, opts}) do
    # When using gettext, we would translate here.
    # For now, we'll just format the message.
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string_for_error(value))
    end)
  end

  # Ecto error metadata can contain tuples (like `{:array, :string}`) which
  # do not implement the String.Chars protocol. This helper function safely
  # converts any value to a string for interpolation in error messages.
  defp to_string_for_error(value) when is_binary(value), do: value
  defp to_string_for_error(value), do: inspect(value)
end
