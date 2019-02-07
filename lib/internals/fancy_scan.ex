defmodule BlackFriday.FancyScan do
  @moduledoc false
  # @spec <<~(order :: %BlackFriday.Order{}, product :: %BlackFriday.Product{}) :: %BlackFriday.Order{}
  defmacro order <<~ product do
    quote bind_quoted: [order: order, product: product] do
      with :ok <- BlackFriday.Checkout.scan(order.owner, product), do: order
    end
  end

  # @spec ~>>(order :: %BlackFriday.Order{}, method :: :total | :checkout) :: Money.t
  defmacro order ~>> method do
    quote bind_quoted: [order: order, method: method] do
      apply(BlackFriday.Checkout, method, [order.owner]).total
    end
  end
end
