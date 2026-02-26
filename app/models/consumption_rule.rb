class ConsumptionRule < ApplicationRecord
  PERIODS = %w[day week month event].freeze

  after_initialize :set_defaults, if: :new_record?
  after_commit :refresh_inventory_dependent_status, on: %i[create update destroy]

  belongs_to :care_subject, polymorphic: true
  belongs_to :consumable_item

  enum :period, { day: "day", week: "week", month: "month", event: "event" }
  enum :kind, { feeding: "feeding", watering: "watering", fertilizing: "fertilizing" }

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true, inclusion: { in: UnitConverter::SUPPORTED_UNITS }
  validates :period, presence: true, inclusion: { in: PERIODS }

  scope :active_now, lambda {
    today = Time.current.to_date
    where(active: true)
      .where("starts_on IS NULL OR starts_on <= ?", today)
      .where("ends_on IS NULL OR ends_on >= ?", today)
  }

  def self.permitted_attributes
    %i[consumable_item_id amount unit period active]
  end

  def daily_amount_in_default_unit(consumable_item = self.consumable_item)
    daily_fraction = case period
    when "day" then 1
    when "week" then 1.0 / 7
    when "month" then 1.0 / 30
    when "event" then nil
    end
    return nil if daily_fraction.nil?

    period_amount_in_default_unit = UnitConverter.to_default(amount, unit, consumable_item.default_unit)
    (period_amount_in_default_unit * daily_fraction).to_d
  end

  private

  def set_defaults
    self.amount ||= 0
    self.unit ||= "g"
    self.period ||= "day"
    self.kind ||= "feeding"
    self.active = true if active.nil?
  end

  def refresh_inventory_dependent_status
    consumable_item.refresh_inventory_dependent_status
  end
end
