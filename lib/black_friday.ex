defmodule BlackFriday do
  @moduledoc """
  `BlackFriday` application. It starts the underlying
    [`DynamicSupervisor`](https://hexdocs.pm/elixir/DynamicSupervisor.html)
    to manage many different checkouts concurrently.
  """
  use Application

  def start(_type, _args) do
    Supervisor.start_link([BlackFriday.Cashier], strategy: :one_for_one)
  end
end
