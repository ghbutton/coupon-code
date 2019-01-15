defmodule CouponCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :coupon_code,
      version: "0.1.3",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Library for generating coupon codes",
      aliases: aliases(),
      package: package(),

      # Docs
      name: "CouponCode",
      source_url: "https://github.com/ghbutton/coupon-code",
      homepage_url: "https://github.com/ghbutton/coupon-code",
      docs: [
        main: "CouponCode", # The main page in the docs
        #        logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
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
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:earmark, "~> 1.0", only: :dev},
      {:dialyxir, "~> 0.5", only: [:dev]}
    ]
  end
end
