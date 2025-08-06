defmodule CopilotWeb.Components.CoreComponents do
  use Phoenix.Component

  @doc """
  Renders a header component.
  """
  attr :current_user, :any, default: nil

  def header(assigns) do
    ~H"""
    <header class="bg-white shadow-md">
      <nav class="mx-auto flex max-w-7xl items-center justify-between p-6 lg:px-8" aria-label="Global">
        <div class="flex lg:flex-1">
          <a href="/" class="-m-1.5 p-1.5">
            <span class="sr-only">Copilot</span>
            <img class="h-8 w-auto" src="/images/phoenix.png" alt="" />
          </a>
        </div>
        <div class="hidden lg:flex lg:gap-x-12">
          <a href="#" class="text-sm font-semibold leading-6 text-gray-900">Features</a>
          <a href="#" class="text-sm font-semibold leading-6 text-gray-900">Marketplace</a>
          <a href="#" class="text-sm font-semibold leading-6 text-gray-900">Company</a>
        </div>
        <div class="hidden lg:flex lg:flex-1 lg:justify-end">
          <%= if @current_user do %>
            <a href="#" class="text-sm font-semibold leading-6 text-gray-900"><%= @current_user.email %></a>
          <% else %>
            <a href="#" class="text-sm font-semibold leading-6 text-gray-900">Log in <span aria-hidden="true">&rarr;</span></a>
          <% end %>
        </div>
      </nav>
    </header>
    """
  end

  @doc """
  Renders flash messages.
  """
  attr :flash, :map, default: %{}

  def flash_group(assigns) do
    ~H"""
    <div
      phx-click="lv:clear-flash"
      phx-value-key="info"
      class="fixed top-2 right-2 z-50 flex w-96 flex-col-reverse"
    >
      <div
        phx-click="lv:clear-flash"
        phx-value-key="error"
        class="fixed top-2 right-2 z-50 flex w-96 flex-col-reverse"
      >
        <%= for {key, message} <- @flash, kind = flash_kind(key) do %>
          <div
            class={[ 
              "relative mt-2 w-full rounded-lg p-4 text-white",
              "bg-red-500": kind == :error,
              "bg-green-500": kind == :info
            ]}
          >
            <p class="font-semibold"><%= message %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp flash_kind(key) do
    case key do
      "info" -> :info
      "error" -> :error
      _ -> :info
    end
  end
end
