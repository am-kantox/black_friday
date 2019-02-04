defmodule BlackFriday.Rule do
  @moduledoc """
  The generic representatioon of the rule. Has the default implementation.

  Call `use BlackFriday.Rule` to implement the behaviour using defaults.
  """

  @doc """
  Quick check that returns whether the rule is applicable to the product.

  Default implementation looks up the config file.
  """
  @callback applicable?(item :: BlackFriday.Product.t()) :: true | false

  @doc "Applies the rule to the order, changing total"
  @callback apply!(order :: BlackFriday.Order.t()) :: Money.t()

  @doc false
  def rules(), do: Application.get_env(:black_friday, :rules, %{})
  @doc false
  def rules(%BlackFriday.Product{code: code}), do: Map.get(rules(), code, [])
  @doc false
  def rules(code) when is_binary(code), do: Map.get(rules(), code, [])
  @doc false
  def rules_impls(), do: rules() |> Enum.flat_map(&elem(&1, 1))

  defmacro __using__(_opts) do
    quote do
      @moduledoc "Implementation of BlackFriday.Rule behaviour"
      @behaviour BlackFriday.Rule

      @impl true
      def applicable?(%BlackFriday.Product{code: code}),
        do: __MODULE__ in BlackFriday.Rule.rules(code)

      @impl true
      def apply!(%BlackFriday.Order{total: total}), do: total

      defoverridable applicable?: 1, apply!: 1
    end
  end

  @doc """
  Performs a reduce operation on the order, calculating total
  """
  @spec reduce(order :: BlackFriday.Order.t()) :: Money.t()
  def reduce(%BlackFriday.Order{items: items}) do
    unknown_rules =
      with [{me, _, _} | _] <- Application.started_applications(),
           {:ok, modules} <- :application.get_key(me, :modules),
           {:ok, original_modules} <- :application.get_key(:black_friday, :modules),
           do: (rules_impls() -- modules) -- original_modules

    case unknown_rules do
      [] -> :ok
      modules -> raise ArgumentError, "Unknown rule(s): #{inspect(modules)}"
    end

    Enum.reduce(
      items,
      %BlackFriday.Order{},
      fn %BlackFriday.Product{code: code} = item,
         %BlackFriday.Order{items: items, total: total} = order ->
        code
        |> rules()
        |> Enum.reduce(
          %BlackFriday.Order{
            order
            | items: [item | items],
              total: Money.add!(total, item.price)
          },
          fn rule, acc ->
            if rule.applicable?(item),
              do: %BlackFriday.Order{
                acc
                | total:
                    rule.apply!(%BlackFriday.Order{
                      acc
                      | items: Enum.filter(acc.items, &(&1.code == item.code))
                    })
              },
              else: acc
          end
        )
      end
    )
  end
end
