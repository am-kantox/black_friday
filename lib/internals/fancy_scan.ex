defmodule BlackFriday.FancyScan do
  @moduledoc false
  # @spec <<~(order :: %BlackFriday.Order{}, product :: %BlackFriday.Product{}) :: %BlackFriday.Order{}
  defmacro order <<~ product do
    quote bind_quoted: [order: order, product: product] do
      with :ok <- BlackFriday.Checkout.scan(order.owner, product), do: order
    end
  end
end
