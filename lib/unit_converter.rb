module UnitConverter
  UNIT_CONVERSIONS = {
    "g" => { "kg" => 0.001 },
    "kg" => { "g" => 1000 },
    "ml" => { "l" => 0.001 },
    "l" => { "ml" => 1000 }
  }.freeze

  SUPPORTED_UNITS = (
    UNIT_CONVERSIONS.keys + UNIT_CONVERSIONS.values.flat_map(&:keys)
  ).uniq.freeze

  class << self
    def convert(quantity, from_unit, to_unit)
      return quantity if from_unit.to_s == to_unit.to_s

      from = normalize_unit(from_unit)
      to = normalize_unit(to_unit)

      conversion = UNIT_CONVERSIONS.dig(from, to) || UNIT_CONVERSIONS.dig(to, from)
      raise ArgumentError, "Cannot convert #{from} to #{to}" if conversion.nil?

      # If conversion is from smaller to larger (e.g. g -> kg), multiply by factor
      if UNIT_CONVERSIONS.dig(from, to)
        quantity * UNIT_CONVERSIONS[from][to]
      else
        quantity / UNIT_CONVERSIONS[to][from]
      end
    end

    def to_default(quantity, unit, default_unit)
      return quantity if unit.to_s == default_unit.to_s

      convert(quantity, unit, default_unit)
    end

    private

    def normalize_unit(unit)
      unit.to_s.downcase.strip
    end
  end
end
