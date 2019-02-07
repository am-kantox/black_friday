defmodule BlackFriday.Rule.ManyAreCheap do
  use BlackFriday.Rule

  @impl true
  def applicable?(%BlackFriday.Product{code: code}) when code in ~w[CF1], do: true

  @impl true
  def applicable?(_), do: false

  @impl true
  def apply!(%BlackFriday.Order{
        items: [%BlackFriday.Product{price: price} | _] = items,
        total: total
      })
      when length(items) == 4 do
    discount =
      price
      |> Money.mult!(length(items))
      |> Money.mult!(Decimal.div(1, 3))

    Money.round(Money.sub!(total, discount))
  end

  @impl true
  def apply!(%BlackFriday.Order{
        items: [%BlackFriday.Product{price: price} | _] = items,
        total: total
      })
      when length(items) > 4 do
    Money.round(Money.sub!(total, Money.mult!(price, Decimal.div(1, 3))))
  end

  @impl true
  def apply!(%BlackFriday.Order{total: total}), do: total
end
