defmodule BlackFriday.Rule.BuyOneGetOneFree do
  use BlackFriday.Rule
  import Integer

  @impl true
  def apply!(%BlackFriday.Order{items: [item | _] = items, total: total})
      when is_even(length(items)),
      do: Money.sub!(total, item.price)

  @impl true
  def apply!(%BlackFriday.Order{total: total}), do: total
end
