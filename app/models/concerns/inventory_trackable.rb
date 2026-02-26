module InventoryTrackable
  extend ActiveSupport::Concern

  DEFAULT_RESTOCK_THRESHOLD_DAYS = 7

  included do
    has_many :consumption_events, as: :care_subject, dependent: :destroy
    has_many :consumption_rules, as: :care_subject, dependent: :destroy
  end

  def on_stock(consumable_item)
    memo(:on_stock, consumable_item.id) { compute_on_stock(consumable_item) }
  end

  def daily_burn(consumable_item)
    memo(:daily_burn, consumable_item.id) { compute_daily_burn(consumable_item) }
  end

  def days_left(consumable_item)
    memo(:days_left, consumable_item.id) { compute_days_left(consumable_item) }
  end

  def restock_date(consumable_item, threshold_days: DEFAULT_RESTOCK_THRESHOLD_DAYS)
    days_left = days_left(consumable_item)
    return nil if days_left.nil?

    days_until_threshold = days_left - threshold_days
    [ days_until_threshold.to_i, 0 ].max.days.from_now.to_date
  end

  def last_consumption_at(category: nil)
    scope = consumption_events.joins(:consumable_item)
    scope = scope.where(consumable_items: { category: category }) if category.present?
    scope.maximum(:occurred_at)
  end

  private

  def memo(bucket, key)
    cache[[bucket, key]] ||= yield
  end

  def cache
    @cache ||= {}
  end

  def compute_on_stock(consumable_item)
    stock_amount = stock_in_default_unit(consumable_item)
    consumed_amount = user_consumption_in_default_unit(consumable_item)
    [ stock_amount - consumed_amount, 0 ].max
  end

  def stock_in_default_unit(consumable_item)
    user.stock_lots
      .where(consumable_item: consumable_item)
      .sum do |lot|
        UnitConverter.to_default(lot.quantity, lot.unit, consumable_item.default_unit)
      end
  end

  def compute_daily_burn(consumable_item)
    active_consumption_rules_for(consumable_item).sum do |rule|
      rule.daily_amount_in_default_unit(consumable_item) || 0.to_d
    end
  end

  def compute_days_left(consumable_item)
    burn = daily_burn(consumable_item)
    return nil if burn <= 0

    stock = on_stock(consumable_item)
    return nil if stock <= 0

    stock / burn
  end

  def active_consumption_rules_for(consumable_item)
    consumption_rules.active_now.where(consumable_item: consumable_item)
  end

  def user_consumption_in_default_unit(consumable_item)
    return 0.to_d unless user.plants.exists? || user.animals.exists?

    consumption_scope(consumable_item).sum do |ev|
      UnitConverter.to_default(ev.quantity, ev.unit, consumable_item.default_unit)
    end
  end

  def consumption_scope(consumable_item)
    item_events = ConsumptionEvent.where(consumable_item: consumable_item)
    item_events.where(care_subject: user.plants).or(item_events.where(care_subject: user.animals))
  end
end
