defmodule BlackFriday.Rule.ForthIsCheap do
  use BlackFriday.Rule

  @impl true
  def applicable?(%BlackFriday.Product{code: code}) when code in ~w[SR1], do: true

  @impl true
  def applicable?(_), do: false

  @impl true
  def apply!(%BlackFriday.Order{items: items, total: total}) when length(items) > 3,
    do: Money.sub!(total, Money.new(:GBP, "0.5"))

  @impl true
  def apply!(%BlackFriday.Order{total: total}), do: total
end
