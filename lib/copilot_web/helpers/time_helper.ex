defmodule CopilotWeb.Helpers.TimeHelper do
  def format_datetime(datetime) do
    Calendar.strftime(datetime, "%d.%m.%Y %H:%M:%S")
  end
end
