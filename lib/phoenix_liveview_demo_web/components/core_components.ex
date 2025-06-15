defmodule PhoenixLiveviewDemoWeb.CoreComponents do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={["bg-white shadow rounded-lg p-6", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :value, :string, required: true
  attr :change, :string, default: nil
  attr :color, :string, default: "blue"

  def metric_card(assigns) do
    ~H"""
    <div class="bg-white overflow-hidden shadow rounded-lg">
      <div class="p-5">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            <div class={["w-8 h-8 rounded-md flex items-center justify-center bg-#{@color}-500"]}>
              <div class="w-4 h-4 bg-white rounded"></div>
            </div>
          </div>
          <div class="ml-5 w-0 flex-1">
            <dl>
              <dt class="text-sm font-medium text-gray-500 truncate"><%= @title %></dt>
              <dd class="text-lg font-medium text-gray-900"><%= @value %></dd>
            </dl>
          </div>
        </div>
      </div>
      <div :if={@change} class="bg-gray-50 px-5 py-3">
        <div class="text-sm">
          <span class="font-medium text-gray-900">Change: <%= @change %></span>
        </div>
      </div>
    </div>
    """
  end

  attr :flash, :map, required: true
  attr :kind, :atom, required: true

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={"flash-#{@kind}"}
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      role="alert"
      phx-click="lv:clear-flash"
      phx-value-key={@kind}
    >
      <p class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <span :if={@kind == :info}>ℹ</span>
        <span :if={@kind == :error}>✕</span>
        <%= msg %>
      </p>
    </div>
    """
  end

  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <.flash flash={@flash} kind={:info} />
    <.flash flash={@flash} kind={:error} />
    """
  end

  attr :suffix, :string, default: nil
  slot :inner_block, required: true

  def live_title(assigns) do
    ~H"""
    <title><%= render_slot(@inner_block) %><%= if @suffix, do: @suffix %></title>
    """
  end
end
