defmodule CopilotWeb.ErrorHTML do
  use Phoenix.Component

  embed_templates "error_html/*"

  # If you want to customize your error pages, you can
  # uncomment the embed_templates/1 call above and define
  # templates inside the `lib/copilot_web/error_html` directory.
  #
  # Othewise, the default error pages from `phoenix` will be used.
end
