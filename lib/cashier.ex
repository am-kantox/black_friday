defmodule BlackFriday.Cashier do
  @moduledoc """
  `DynamicSupervisor` to supervise `BlackFriday.Chekout`s.
  """

  use DynamicSupervisor

  @doc false
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  def checkout!() do
    DynamicSupervisor.start_child(__MODULE__, {BlackFriday.Checkout, []})
  end

  @doc false
  def order!(),
    do: with({:ok, pid} <- checkout!(), do: {:ok, BlackFriday.Checkout.order(pid)})

  @doc false
  @impl true
  def init(opts),
    do: DynamicSupervisor.init(max_children: 1_000, strategy: :one_for_one, extra_arguments: opts)
end
