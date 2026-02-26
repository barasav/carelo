require "test_helper"

class ConsumptionEventTest < ActiveSupport::TestCase
  test "fixture watering_one is valid" do
    assert consumption_events(:watering_one).valid?
  end

  test "fixture fertilizing_one is valid" do
    assert consumption_events(:fertilizing_one).valid?
  end

  test "valid consumption event with required attributes" do
    event = ConsumptionEvent.new(
      care_subject: plants(:one),
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "ml",
      occurred_at: Time.current
    )
    assert event.valid?, event.errors.full_messages.join(", ")
  end

  test "invalid without quantity" do
    event = ConsumptionEvent.new(
      care_subject: plants(:one),
      consumable_item: consumable_items(:water),
      quantity: nil,
      unit: "ml",
      occurred_at: Time.current
    )
    assert_not event.valid?
  end

  test "invalid without occurred_at" do
    event = ConsumptionEvent.new(
      care_subject: plants(:one),
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "ml",
      occurred_at: nil
    )
    assert_not event.valid?
  end

  test "invalid without care_subject" do
    event = ConsumptionEvent.new(
      care_subject: nil,
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "ml",
      occurred_at: Time.current
    )
    assert_not event.valid?
  end

  test "unit must be a supported UnitConverter unit" do
    event = ConsumptionEvent.new(
      care_subject: plants(:one),
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "oz",
      occurred_at: Time.current
    )
    assert_not event.valid?
    assert event.errors[:unit].any?
  end

  test "quantity must be greater than or equal to 0" do
    event = ConsumptionEvent.new(
      care_subject: plants(:one),
      consumable_item: consumable_items(:water),
      quantity: -1,
      unit: "ml",
      occurred_at: Time.current
    )
    assert_not event.valid?
  end

  test "belongs to plant as care_subject" do
    event = consumption_events(:watering_one)
    assert_equal plants(:one), event.care_subject
  end

  test "refreshes plant care status when water consumption event is created" do
    plant = plants(:one)
    plant.update!(watering_interval_days: 7, fertilizing_interval_days: 30, watered_ok: false, fertilized_ok: false)

    plant.consumption_events.joins(:consumable_item).where(consumable_items: { category: "water" }).destroy_all

    ConsumptionEvent.create!(
      care_subject: plant,
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "ml",
      occurred_at: 1.day.ago
    )

    plant.reload
    assert_equal true, plant.watered_ok
  end

  test "refreshes plant care status when fertilizer consumption event is created" do
    plant = Plant.create!(
      name: "No fertilizing yet",
      user: users(:one),
      watering_interval_days: 7,
      fertilizing_interval_days: 30,
      watered_ok: true,
      fertilized_ok: false
    )
    ConsumptionEvent.create!(
      care_subject: plant,
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "ml",
      occurred_at: 1.day.ago
    )
    plant.reload
    assert_equal true, plant.watered_ok

    ConsumptionEvent.create!(
      care_subject: plant,
      consumable_item: consumable_items(:fertilizer),
      quantity: 5,
      unit: "g",
      occurred_at: 1.day.ago
    )

    plant.reload
    assert_equal true, plant.fertilized_ok
  end

  test "refreshes plant care status when water consumption event is destroyed" do
    plant = Plant.create!(
      name: "Only one watering",
      user: users(:one),
      watering_interval_days: 7,
      fertilizing_interval_days: 30
    )
    water_event = ConsumptionEvent.create!(
      care_subject: plant,
      consumable_item: consumable_items(:water),
      quantity: 200,
      unit: "ml",
      occurred_at: 1.day.ago
    )
    plant.reload
    assert_equal true, plant.watered_ok

    water_event.destroy!

    plant.reload
    assert_equal false, plant.watered_ok
  end

  test "does not refresh plant care status for food consumption event" do
    plant = plants(:one)
    plant.update!(watering_interval_days: 7, fertilizing_interval_days: 30)

    animal = animals(:one)
    ConsumptionEvent.create!(
      care_subject: animal,
      consumable_item: consumable_items(:cat_food),
      quantity: 50,
      unit: "g",
      occurred_at: 1.day.ago
    )

    plant.reload
    assert plant.persisted?
  end
end
