defmodule CopilotWeb.PageLive do
  use CopilotWeb, :live_view

  alias CopilotWeb.Components.CoreComponents

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :current_user, socket.assigns[:current_user])}
  end

  def render(assigns) do
    ~H"""
    <CoreComponents.header current_user={@current_user} />
    <CoreComponents.flash_group flash={@flash} />
    <div class="px-4 py-10 sm:px-6 sm:py-14 lg:px-8">
      <div class="mx-auto max_w-2xl">
        <h1 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Hello from LiveView!</h1>
        <p class="mt-6 text-lg leading-8 text-gray-600">
          This is a basic Phoenix LiveView page. You can start building your interactive features here.
        </p>
      </div>
    </div>
    """
  end
end
