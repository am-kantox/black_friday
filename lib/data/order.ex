defmodule BlackFriday.Order do
  @moduledoc """
  Structure describing the order (cart).
  """

  defstruct items: [],
            total: :black_friday |> Application.get_env(:default_currency, :GBP) |> Money.new(0)

  @type t() :: %BlackFriday.Order{items: [BlackFriday.Product.t()], total: Money.t()}
end
