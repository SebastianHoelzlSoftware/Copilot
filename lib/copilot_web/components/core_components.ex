defmodule CopilotWeb.Components.CoreComponents do
  use Phoenix.Component

  import CopilotWeb.Gettext

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
            class={
              "relative mt-2 w-full rounded-lg p-4 text-white " <>
              case kind do
                :error -> "bg-red-500"
                :info -> "bg-green-500"
                _ -> ""
              end
            }
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

  slot :content, required: true
  slot :actions, required: true

  def simple_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@for}
      id={@id}
      phx-submit={@phx_submit}
      phx-change={@phx_change}
      class="max-w-md mx-auto mt-8"
    >
      <div class="space-y-6">
        <%= render_slot(@content, f) %>
        <div class="flex justify-end">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week rating)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = field.errors

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "datetime-local"} = assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
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

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(CopilotWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(CopilotWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end