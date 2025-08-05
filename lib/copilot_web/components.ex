defmodule CopilotWeb.Components do
  defmacro __using__(_opts) do
    quote do
      import Phoenix.Component
      import Phoenix.HTML
      import Phoenix.LiveView.Helpers
      import CopilotWeb.Gettext
      unquote(CopilotWeb.verified_routes())
    end
  end
end
