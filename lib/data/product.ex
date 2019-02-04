defmodule BlackFriday.Product do
  @moduledoc """
  Structure describing the product.
  """

  defstruct ~w|code name price|a

  @type t() :: %BlackFriday.Product{code: binary(), name: binary(), price: Money.t()}

  alias BlackFriday.Product, as: P

  @valid_products Application.get_env(:black_friday, :products)
  @valid_codes Enum.map(@valid_products, & &1.code)

  @doc "Returns `true` if the product is valid, false otherwise"
  @spec valid?(product :: t() | binary()) :: true | false
  def valid?(%P{code: code}) when code in @valid_codes, do: true
  def valid?(code) when code in @valid_codes, do: true

  # For dynamic code check, uncomment the following line:
  # def valid?(%P{code: code}), do:
  #   code in Application.get_env(:black_friday, :products)

  def valid?(_), do: false

  @doc "Returns all products known to the system"
  @spec all() :: [t()]
  def all() do
    Enum.map(@valid_products, fn %{price: {currency, amount}} = product ->
      struct(BlackFriday.Product, %{product | price: Money.new(currency, amount)})
    end)
  end

  @doc "Finds a product by its code"
  @spec find(code :: binary()) :: [t()]
  def find(code) when code in @valid_codes,
    do: Enum.find(all(), &(&1.code == code))

  def find(_), do: nil
end
