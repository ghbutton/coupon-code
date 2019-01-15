defmodule CouponCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :coupon_code,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
       description: "This fly into the sky",
       aliases: aliases(),
       package: package()
    ]
  end

  defp package do
    [
      maintainers: ["ghbutton"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ghbutton/coupon-code"}
    ]
  end

  defp aliases do
      [c: "compile"]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
   [
   ]
  end
end
