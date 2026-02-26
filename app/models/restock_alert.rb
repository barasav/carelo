class RestockAlert < ApplicationRecord
  belongs_to :care_subject, polymorphic: true
  belongs_to :consumable_item

  scope :unacknowledged, -> { where(acknowledged: false) }
end
