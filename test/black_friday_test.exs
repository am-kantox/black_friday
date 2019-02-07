defmodule BlackFridayTest do
  use ExUnit.Case, async: false
  doctest BlackFriday

  alias BlackFriday.Product, as: P
  import BlackFriday.FancyScan

  setup do
    {:ok, pid1} = BlackFriday.Cashier.checkout!()
    {:ok, pid2} = BlackFriday.Cashier.checkout!()

    on_exit(fn ->
      BlackFriday.Checkout.checkout(pid2)
    end)

    # Returns extra metadata to be merged into context
    {:ok, [pid1: pid1, pid2: pid2]}
  end

  test "Product.valid?/1" do
    assert P.valid?(%P{code: "GR1"})
    refute P.valid?(%P{code: "GR2"})
  end

  test "BlackFriday.Cashier.checkout!/0 and BlackFriday.Checkout.checkout/1" do
    with zero <- Money.new(:GBP, 0),
         count <- DynamicSupervisor.count_children(BlackFriday.Cashier).workers,
         {:ok, pid} <- BlackFriday.Cashier.checkout!(),
         ^count = DynamicSupervisor.count_children(BlackFriday.Cashier).workers - 1,
         %BlackFriday.Order{items: [], total: ^zero} = BlackFriday.Checkout.total(pid) do
      # to let it exit
      Process.sleep(100)
      assert %BlackFriday.Order{items: [], total: ^zero} = BlackFriday.Checkout.checkout(pid)
      assert count == DynamicSupervisor.count_children(BlackFriday.Cashier).workers
    end
  end

  test "Test Cart (self-destroying)", context do
    assert %BlackFriday.Order{owner: context[:pid1], items: [], total: Money.zero(:GBP)} ==
             BlackFriday.Checkout.total(context[:pid1])

    one_tea_price = Money.new(:GBP, "3.11")
    two_tea_price = Money.new(:GBP, "6.22")
    three_sr_price = Money.new(:GBP, "21.22")
    four_sr_price = Money.new(:GBP, "25.72")
    three_cf_price = Money.new(:GBP, "59.41")
    four_cf_price = Money.new(:GBP, "55.67")

    BlackFriday.Checkout.scan(context[:pid1], BlackFriday.Product.find("GR1"))
    assert %BlackFriday.Order{total: ^one_tea_price} = BlackFriday.Checkout.total(context[:pid1])
    BlackFriday.Checkout.scan(context[:pid1], "GR1")
    assert %BlackFriday.Order{total: ^one_tea_price} = BlackFriday.Checkout.total(context[:pid1])
    BlackFriday.Checkout.scan(context[:pid1], "GR1")
    assert %BlackFriday.Order{total: ^two_tea_price} = BlackFriday.Checkout.total(context[:pid1])

    BlackFriday.Checkout.scan(context[:pid1], "SR1")
    BlackFriday.Checkout.scan(context[:pid1], "SR1")
    BlackFriday.Checkout.scan(context[:pid1], "SR1")
    assert %BlackFriday.Order{total: ^three_sr_price} = BlackFriday.Checkout.total(context[:pid1])

    BlackFriday.Checkout.scan(context[:pid1], "SR1")
    assert %BlackFriday.Order{total: ^four_sr_price} = BlackFriday.Checkout.total(context[:pid1])

    BlackFriday.Checkout.scan(context[:pid1], "CF1")
    BlackFriday.Checkout.scan(context[:pid1], "CF1")
    BlackFriday.Checkout.scan(context[:pid1], "CF1")
    assert %BlackFriday.Order{total: ^three_cf_price} = BlackFriday.Checkout.total(context[:pid1])

    BlackFriday.Checkout.scan(context[:pid1], "CF1")

    assert %BlackFriday.Order{total: ^four_cf_price} =
             BlackFriday.Checkout.checkout(context[:pid1])

    Process.sleep(100)
    refute Process.alive?(context[:pid1])
  end

  test "Fancy Scan", _context do
    {:ok, order} = BlackFriday.Order.new()
    three_tea_price = Money.new(:GBP, "6.22")

    bucket =
      order
      <<~ BlackFriday.Product.find("GR1")
      <<~ BlackFriday.Product.find("GR1")
      <<~ BlackFriday.Product.find("GR1")

    assert ^three_tea_price = BlackFriday.Checkout.checkout(bucket.owner).total
  end

  test "Fancy Total", _context do
    {:ok, order} = BlackFriday.Order.new()
    three_tea_price = Money.new(:GBP, "6.22")

    total =
      order
      <<~ BlackFriday.Product.find("GR1")
      <<~ BlackFriday.Product.find("GR1")
      <<~ BlackFriday.Product.find("GR1")
      ~>> :checkout

    assert three_tea_price == total
  end

  test "Test Several Carts (concurrent)", _context do
    # pending
  end
end
