defmodule CouponCode do
  @moduledoc """
  This module implements a coupon generating algorithm described [here](https://metacpan.org/pod/distribution/Algorithm-CouponCode/lib/Algorithm/CouponCode.pm).
  With inspiration from the [ruby version](https://github.com/baxang/coupon-code).
  """

  @posibilities ~w(0 1 2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P Q R T U V W X Y)
  @parts 3
  @length 4

  @doc ~S"""
  Generates a coupon code.

  Accepts a keyword list of options:

    * `:parts`  — number of dash-separated parts (default `#{@parts}`)
    * `:length` — number of characters per part, including the checksum
      character (default `#{@length}`)

  ## Examples

    iex> coupon_code = CouponCode.generate()
    iex> {:ok, _} = CouponCode.validate(coupon_code)
    iex> longer_coupon_code = CouponCode.generate([parts: 5])
    iex> {:ok, _} = CouponCode.validate(longer_coupon_code, 5)
    iex> wide_coupon_code = CouponCode.generate(parts: 2, length: 6)
    iex> {:ok, _} = CouponCode.validate(wide_coupon_code, 2, 6)
  """
  @spec generate(keyword()) :: String.t()
  def generate(options \\ []) do
    num_parts = options[:parts] || @parts
    length = options[:length] || @length

    for num_part <- 1..num_parts do
      part =
        for _ <- 1..length - 1 do
          random_symbol()
        end
        |> Enum.join("")
      part <> check_digit(part, num_part)
    end
    |> Enum.join("-")
  end

  @doc ~S"""
  Validates a coupon code.

  Takes the raw coupon `text`, the expected number of parts (`num_parts`,
  default `#{@parts}`), and the expected length of each part (`length`,
  default `#{@length}`). The two numeric arguments must match the values
  passed to `generate/1` when the code was created.

  Returns `{:ok, normalized_code}` on success (with ambiguous characters
  mapped: `O`→`0`, `I`→`1`, `Z`→`2`, `S`→`5`), or `{:error, reason}`.

  ## Examples

      iex> CouponCode.validate("TPV1-EHPN-ZVKT")
      {:ok, "TPV1-EHPN-2VKT"}

      iex> code = CouponCode.generate(parts: 4, length: 6)
      iex> {:ok, _} = CouponCode.validate(code, 4, 6)
  """
  @spec validate(String.t(), integer(), integer()) :: {:ok, String.t()} | {:error, String.t()}
  def validate(text, num_parts \\ @parts, length \\ @length) do
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
      |> Enum.chunk_every(length)

    if length(chunks) == num_parts do
      validate_chunks(chunks, 0, length, [])
    else
      {:error, "Incorrect number of parts"}
    end
  end

  defp validate_chunks([], _index, _length, result) do
    {:ok, Enum.join(Enum.reverse(result), "-")}
  end

  defp validate_chunks([chunk | rest], index, length, acc) do
    text = Enum.slice(chunk, 0..-2//1) |> Enum.join()
    check = Enum.slice(chunk, -1..-1) |> hd

    if check_digit(text, index + 1) == check && length(chunk) == length do
      validate_chunks(rest, index + 1, length, [text <> check | acc])
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
