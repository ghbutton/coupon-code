defmodule CouponCodeTest do
  use ExUnit.Case
  doctest CouponCode

  describe "generate/1" do
    test "returns a 3-part, 4-character code by default" do
      code = CouponCode.generate()
      assert Regex.match?(~r/^[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}$/, code)
    end

    test "respects the :parts option" do
      code = CouponCode.generate(parts: 5)
      assert length(String.split(code, "-")) == 5
      assert Regex.match?(~r/^([0-9A-Z]{4}-){4}[0-9A-Z]{4}$/, code)
    end

    test "respects the :length option" do
      code = CouponCode.generate(length: 6)
      parts = String.split(code, "-")
      assert length(parts) == 3
      assert Enum.all?(parts, &(String.length(&1) == 6))
    end

    test "does not produce the ambiguous characters O, I, S, Z" do
      for _ <- 1..50 do
        code = CouponCode.generate(parts: 6)
        refute Regex.match?(~r/[OISZ]/, code)
      end
    end

    test "generated codes pass validation" do
      for _ <- 1..50 do
        code = CouponCode.generate()
        assert {:ok, ^code} = CouponCode.validate(code)
      end
    end

    test "generated codes with custom :parts validate against the same :parts" do
      code = CouponCode.generate(parts: 4)
      assert {:ok, ^code} = CouponCode.validate(code, 4)
    end
  end

  describe "validate/2" do
    test "returns {:ok, code} for a valid code" do
      code = CouponCode.generate()
      assert {:ok, ^code} = CouponCode.validate(code)
    end

    test "upcases lowercase input" do
      code = CouponCode.generate()
      assert {:ok, ^code} = CouponCode.validate(String.downcase(code))
    end

    test "strips non-alphanumeric characters" do
      code = CouponCode.generate()
      noisy = String.replace(code, "-", " / ")
      assert {:ok, ^code} = CouponCode.validate(noisy)
    end

    test "normalizes O to 0, I to 1, Z to 2, S to 5" do
      code = CouponCode.generate()

      obfuscated =
        code
        |> String.replace("0", "O")
        |> String.replace("1", "I")
        |> String.replace("2", "Z")
        |> String.replace("5", "S")

      assert {:ok, ^code} = CouponCode.validate(obfuscated)
    end

    test "returns error for wrong number of parts" do
      code = CouponCode.generate(parts: 2)
      assert {:error, "Incorrect number of parts"} = CouponCode.validate(code)
    end

    test "returns error when checksum does not match" do
      assert {:error, "Checksum did not match"} =
               CouponCode.validate("AAAA-AAAA-AAAA")
    end

    test "returns error for a part shorter than the expected length" do
      assert {:error, _} = CouponCode.validate("ABC-DEFG-HJKL")
    end

    test "accepts custom num_parts" do
      code = CouponCode.generate(parts: 5)
      assert {:ok, ^code} = CouponCode.validate(code, 5)
      assert {:error, "Incorrect number of parts"} = CouponCode.validate(code, 3)
    end
  end
end
