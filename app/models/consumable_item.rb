class ConsumableItem < ApplicationRecord
  CATEGORIES = %w[food fertilizer water supplement].freeze

  after_initialize :set_defaults, if: :new_record?

  belongs_to :user

  has_many :stock_lots, dependent: :destroy
  has_many :consumption_events, dependent: :destroy
  has_many :consumption_rules, dependent: :destroy

  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :default_unit, presence: true, inclusion: { in: UnitConverter::SUPPORTED_UNITS }

  scope :for_food, -> { where(category: "food") }

  def self.permitted_attributes
    %i[name category default_unit]
  end

  def total_stock
    stock_lots.sum { |lot| UnitConverter.to_default(lot.quantity, lot.unit, default_unit) }
  end

  def total_daily_consumption
    (user.plants + user.animals).sum { |cs| cs.daily_burn(self) }
  end

  def days_left
    care_subjects = care_subjects_with_rules(user: user)
    return nil if care_subjects.empty?

    days_values = care_subjects.filter_map { |care_subject| care_subject.days_left(self) }
    return nil if days_values.empty?

    days_values.min
  end

  def refresh_inventory_dependent_status(threshold_days: InventoryTrackable::DEFAULT_RESTOCK_THRESHOLD_DAYS)
    care_subjects = care_subjects_with_rules
    care_subjects.each do |care_subject|
      refresh_restock_alert_for(care_subject, threshold_days)
    end

    RestockAlert.where(consumable_item: self).where.not(care_subject: care_subjects).destroy_all
    Animal.refresh_feeding_status_for_consumable_item(self)
  end

  private

  def set_defaults
    self.default_unit ||= "g"
  end

  def care_subjects_with_rules(user: nil)
    subjects = consumption_rules
      .merge(ConsumptionRule.active_now)
      .includes(:care_subject)
      .map(&:care_subject)
      .compact
      .uniq
    user ? subjects.select { |cs| cs.user_id == user.id } : subjects
  end

  def refresh_restock_alert_for(care_subject, threshold_days)
    days_left = care_subject.days_left(self)
    alert = RestockAlert.find_by(care_subject: care_subject, consumable_item: self)

    if days_left.nil? || days_left >= threshold_days
      alert&.destroy
    else
      (alert || RestockAlert.new(care_subject: care_subject, consumable_item: self)).update!(
        days_left: days_left,
        restock_by: care_subject.restock_date(self, threshold_days: threshold_days),
        acknowledged: false
      )
    end
  end
end
