class Plant < ApplicationRecord
  include InventoryTrackable

  belongs_to :user
  has_many :restock_alerts, as: :care_subject, dependent: :destroy

  validates :name, presence: true
  validates :watering_interval_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :fertilizing_interval_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate  :blooming_end_date_after_or_equal_to_start_date

  def self.permitted_attributes
    %i[
      name blooming_start_date blooming_end_date location light
      watering_amount fertilizer_type fertilizer_amount
      watering_interval_days fertilizing_interval_days
    ]
  end

  def blooming_season?
    blooming_start_date.present? || blooming_end_date.present?
  end

  def update_care_status!
    watered_ok = care_event_within_frequency?("water", watering_interval_days)
    fertilized_ok = care_event_within_frequency?("fertilizer", fertilizing_interval_days)

    # Skip update when already checked and status unchanged
    return if last_checked_at.present? && self.watered_ok == watered_ok && self.fertilized_ok == fertilized_ok

    update!(watered_ok: watered_ok, fertilized_ok: fertilized_ok, last_checked_at: Time.current)
  end

  private

  def care_event_within_frequency?(category, interval_days)
    return nil if interval_days.blank? || interval_days <= 0

    last_at = last_consumption_at(category: category)
    return false if last_at.nil?

    cutoff = interval_days.days.ago
    last_at >= cutoff
  end

  def blooming_end_date_after_or_equal_to_start_date
    return if blooming_start_date.blank? || blooming_end_date.blank?

    errors.add(:blooming_end_date, :after_start_date) if blooming_end_date < blooming_start_date
  end
end
