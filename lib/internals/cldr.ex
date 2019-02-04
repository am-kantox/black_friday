defmodule BlackFriday.Cldr do
  @doc """
  Defines a backend module that will host our `Cldr` configuration and public API.

  Most function calls in `Cldr` will be calls to functions on this module.
  """
  use Cldr, locales: ~w[en], default_locale: "en"
end
