defmodule CopilotWeb.ErrorJSON do
  @moduledoc """
  The default error view for JSON API responses.
  By default, it will handle 404 and 500 errors.
  """

  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

    def render("400.json", _assigns) do
    %{errors: %{detail: "The request body is malformed. Please check the JSON syntax."}}
  end

  def render("401.json", _assigns) do
    %{errors: %{detail: "Unauthorized"}}
  end

  def render("403.json", _assigns) do
    %{errors: %{detail: "Forbidden"}}
  end

  # Renders changeset errors.
  def render("error.json", %{result: %Ecto.Changeset{} = changeset}) do
    # When the changeset has action :insert or :update, we have a map of errors.
    # When the changeset has action :delete, the error is a string.
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp translate_error(msg), do: msg
end
