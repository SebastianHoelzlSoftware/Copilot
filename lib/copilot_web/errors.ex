defmodule CopilotWeb.Errors do
  @moduledoc """
  This module defines custom error handling implementations for specific
  exceptions, allowing them to be rendered as clean JSON responses instead
  of showing a debug page in development.
  """

  defimpl Plug.Exception, for: Plug.Parsers.ParseError do
    @moduledoc "Tells Phoenix how to handle JSON parsing errors from Plug."
    def actions(_exception), do: []
    def status(_exception), do: 400
  end
end
