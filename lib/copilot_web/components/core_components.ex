defmodule CopilotWeb.Components.CoreComponents do
  use Phoenix.Component

  @doc """
  Renders a header component.
  """
  attr :current_user, :any, default: nil
  slot :inner_block, default: nil

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
      <%= if @inner_block do %>
        <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
          <%= render_slot(@inner_block) %>
        </div>
      <% end %>
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

  @doc """
  Renders a simple form.
  """
  attr :for, :any, required: true
  attr :id, :string, default: nil
  attr :phx_submit, :string, required: true
  attr :phx_change, :string, required: true

  slot :inner_block, required: true
  slot :actions, required: true

  def simple_form(assigns) do
    ~H"""
    <.form
      for={@for}
      id={@id}
      phx-submit={@phx_submit}
      phx-change={@phx_change}
      class="max-w-md mx-auto mt-8"
    >
      <div class="space-y-6">
        <%= render_slot(@inner_block) %>
        <div class="flex justify-end">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders an input field.
  """
  attr :field, :any, required: true
  attr :type, :string, required: true
  attr :label, :string, required: true
  attr :options, :list, default: []

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <label for={@field.id} class="block text-sm font-medium text-gray-700"><%= @label %></label>
      <select field={@field} options={@options} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" />
      <error_tag field={@field} />
    </div>
    """
  end

  def input(%{type: "datetime-local"} = assigns) do
    ~H"""
    <div>
      <label for={@field.id} class="block text-sm font-medium text-gray-700"><%= @label %></label>
      <datetime_local_input field={@field} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" />
      <error_tag field={@field} />
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div>
      <label for={@field.id} class="block text-sm font-medium text-gray-700"><%= @label %></label>
      <text_input field={@field} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm" />
      <error_tag field={@field} />
    </div>
    """
  end


  @doc """
  Renders a button.
  """
  slot :inner_block, required: true
  attr :rest, :global

  def button(assigns) do
    ~H"""
    <button {@rest} class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a table.
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true

  slot :col, required: true do
    attr :label, :string
  end

  def table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table id={@id} class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <%= for col <- @col do %>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                <%= col.label %>
              </th>
            <% end %>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for row <- @rows do %>
            <tr>
              <%= for col <- @col do %>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <%= render_slot(col, row) %>
                </td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end