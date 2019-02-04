defmodule BlackFriday.Checkout do
  @moduledoc """
  The main worker for making concurrent checkout. Supervised by `BlackFriday.Cashier`.
  """
  use GenServer, restart: :transient

  alias BlackFriday.Product, as: P
  alias BlackFriday.Order, as: O

  # TODO Implement Collectable for %BlackFriday.Order{} to use in comprehensions

  @doc "Scans the item in the cart, given product instance"
  @spec scan(pid :: pid(), product :: P.t() | binary()) :: O.t()
  def scan(pid, %P{} = product),
    do: GenServer.cast(pid, {:scan, product})

  @doc "Scans the item in the cart, given scan code"
  def scan(pid, <<product::binary-size(3)>>),
    do: GenServer.cast(pid, {:scan, P.find(product)})

  @doc "Returns total, does not kill itself"
  @spec total(pid :: pid()) :: Money.t()
  def total(pid), do: GenServer.call(pid, :total)

  @doc "Returns total, kills itself"
  @spec checkout(pid :: pid()) :: Money.t()
  def checkout(pid), do: GenServer.call(pid, :checkout)

  # implementation details

  @spec do_total(state :: O.t()) :: O.t()
  defp do_total(%O{} = order), do: BlackFriday.Rule.reduce(order)

  @doc false
  def start_link(opts), do: GenServer.start_link(__MODULE__, %O{}, opts)

  @doc false
  @impl true
  def init(%O{}) do
    {:ok, %O{}}
  end

  @doc false
  @impl true
  def handle_call(:total, _from, %O{} = state) do
    {:reply, do_total(state), state}
  end

  @doc false
  @impl true
  def handle_call(:checkout, _from, %O{} = state) do
    {:stop, :normal, do_total(state), %O{}}
  end

  @doc false
  @impl true
  def handle_cast({:scan, %P{} = product}, %O{items: items} = state) do
    {:noreply, %O{state | items: [product | items]}}
  end
end
