use Mix.Config

# GR1 Green tea £3.11
# SR1 Strawberries £5.00
# CF1 Coffee £11.23

# Hardcoded here as for MVP. Also, it’s way faster.

# If needed, use
#   https://hexdocs.pm/elixir/master/Application.html#put_env/4
# and update BlackFriday.Product.valid?/1 to dynamic equivalent (commented)
config :black_friday, :products, [
  %{code: "GR1", name: "Green tea", price: {:GBP, "3.11"}},
  %{code: "SR1", name: "Strawberries", price: {:GBP, "5.00"}},
  %{code: "CF1", name: "Coffee", price: {:GBP, "11.23"}}
]

config :black_friday, :default_currency, :GBP

config :black_friday, :rules, %{
  "GR1" => [BlackFriday.Rule.BuyOneGetOneFree],
  "SR1" => [BlackFriday.Rule.ForthIsCheap],
  "CF1" => [BlackFriday.Rule.ManyAreCheap]
}

config :ex_money, default_cldr_backend: BlackFriday.Cldr

if File.exists?("config/#{Mix.env()}.exs"),
  do: import_config("#{Mix.env()}.exs")
