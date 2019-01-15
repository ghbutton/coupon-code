defmodule CouponCode do
  @moduledoc """
  This module implements a coupon generating algorithm described [here](https://metacpan.org/pod/distribution/Algorithm-CouponCode/lib/Algorithm/CouponCode.pm).
  With inspiration from the [ruby version](https://github.com/baxang/coupon-code).
  """

  @posibilities ~w(0 1 2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P Q R T U V W X Y)
  @parts 3
  @length 4

  @doc ~S"""
  Generates a coupon code with the specified number of parts.

  ## Examples

    iex> #Seeding data so that example works
    iex> :rand.seed(:exsplus, {101, 102, 103})
    iex> CouponCode.generate()
    "ALCB-J7Q6-15UB"
    iex> CouponCode.generate([parts: 5])
    "T59C-WMAD-KFEM-XQX2-NY4K"
  """
  @spec generate([...]) :: String.t()
  def generate(options \\ [parts: @parts]) do
    num_parts = options[:parts]

    for num_part <- 1..num_parts do
      part =
        for _ <- 1..@length - 1 do
          random_symbol()
        end
        |> Enum.join("")
      part <> check_digit(part, num_part)
    end
    |> Enum.join("-")
  end

  @doc ~S"""
  Validates a coupon code with the specified number of parts.

  ## Examples

    iex> CouponCode.validate("TPV1-EHPN-ZVKT")
    {:ok, "TPV1-EHPN-2VKT"}
  """
  @spec validate(String.t(), Integer.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate(text, num_parts \\ @parts) do
    text =
      String.upcase(text)
      |> String.replace(~r/[^0-9A-Z]+/, "")
      |> String.replace(~r/O/, "0")
      |> String.replace(~r/I/, "1")
      |> String.replace(~r/Z/, "2")
      |> String.replace(~r/S/, "5")

    chunks =
      text
      |> String.graphemes
      |> Enum.chunk_every(@length)

    if length(chunks) == num_parts do
      validate_chunks(chunks, 0, [])
    else
      {:error, "Incorrect number of parts"}
    end
  end

  defp validate_chunks([], _index, result) do
    {:ok, Enum.join(Enum.reverse(result), "-")}
  end

  defp validate_chunks(_chunks, _index, {:error, message}) do
    {:error, message}
  end

  defp validate_chunks([chunk | rest], index, acc) do
    text = Enum.slice(chunk, 0..-2) |> Enum.join()
    check = Enum.slice(chunk, -1..-1) |> hd

    if check_digit(text, index + 1) == check && length(chunk) == @length do
      validate_chunks(rest, index + 1, [text <> check | acc])
    else
      {:error, "Checksum did not match"}
    end
  end

  defp check_digit(text, check) do
    text
    |> String.graphemes
    |> Enum.reduce(check, fn(character, check) ->
      pos = Enum.find_index(@posibilities, fn(current) -> current == character end)
      check * 19 + pos
    end)
    # Get the remainder after dividing by 31
    |> (fn(check) -> Enum.at(@posibilities, rem(check, 31)) end).()
  end

  defp random_symbol do
    Enum.random(@posibilities)
  end
end
