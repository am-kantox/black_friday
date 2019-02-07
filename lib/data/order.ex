defmodule BlackFriday.Order do
  @moduledoc """
  Structure describing the order (cart).
  """

  defstruct owner: nil,
            items: [],
            total: :black_friday |> Application.get_env(:default_currency, :GBP) |> Money.new(0)

  @type t() :: %BlackFriday.Order{
          owner: pid(),
          items: [BlackFriday.Product.t()],
          total: Money.t()
        }

  defdelegate new(), to: BlackFriday.Cashier, as: :order!
end
