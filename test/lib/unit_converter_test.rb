require "test_helper"

class UnitConverterTest < ActiveSupport::TestCase
  test "convert g to kg" do
    assert_equal 1, UnitConverter.convert(1000, "g", "kg")
  end

  test "convert kg to g" do
    assert_equal 1000, UnitConverter.convert(1, "kg", "g")
  end

  test "convert ml to l" do
    assert_equal 1, UnitConverter.convert(1000, "ml", "l")
  end

  test "convert l to ml" do
    assert_equal 1000, UnitConverter.convert(1, "l", "ml")
  end

  test "to_default returns same value when unit matches" do
    assert_equal 100, UnitConverter.to_default(100, "g", "g")
  end

  test "to_default converts when unit differs" do
    assert_equal 1, UnitConverter.to_default(1000, "g", "kg")
  end

  test "SUPPORTED_UNITS includes g kg ml l" do
    assert_equal %w[g kg l ml].sort, UnitConverter::SUPPORTED_UNITS.sort
  end

  test "raises when conversion not supported" do
    assert_raises(ArgumentError) do
      UnitConverter.convert(1, "g", "ml")
    end
  end
end
