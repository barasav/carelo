require "test_helper"

class PlantTest < ActiveSupport::TestCase
  test "valid plant with required attributes" do
    plant = Plant.new(name: "Kaktus", user: users(:one))
    assert plant.valid?, plant.errors.full_messages.join(", ")
  end

  test "invalid without name" do
    plant = Plant.new(name: nil, user: users(:one))
    assert_not plant.valid?
  end

  test "invalid without user" do
    plant = Plant.new(name: "Test", user: nil)
    assert_not plant.valid?
  end

  test "belongs to user" do
    plant = plants(:one)
    assert_equal users(:one), plant.user
  end

  test "watering_interval_days must be greater than 0 when present" do
    plant = Plant.new(name: "Test", user: users(:one), watering_interval_days: -1)
    assert_not plant.valid?
  end

  test "watering_amount can be nil" do
    plant = Plant.new(name: "Test", user: users(:one), watering_amount: nil)
    assert plant.valid?
  end

  test "fixture one has expected attributes" do
    plant = plants(:one)
    assert_equal "Fíkus", plant.name
    assert_equal "Obývák", plant.location
    assert_equal "200", plant.watering_amount.to_s
    assert_equal 7, plant.watering_interval_days
  end

  test "fixture two has care status" do
    plant = plants(:two)
    assert_equal true, plant.watered_ok
    assert_equal true, plant.fertilized_ok
  end

  test "includes InventoryTrackable" do
    plant = plants(:one)
    assert plant.respond_to?(:on_stock)
    assert plant.respond_to?(:daily_burn)
    assert plant.respond_to?(:days_left)
    assert plant.respond_to?(:last_consumption_at)
  end

  test "update_care_status! sets watered_ok to false when last water consumption exceeds interval" do
    plant = Plant.create!(
      name: "Expired watering",
      user: users(:one),
      watering_interval_days: 7,
      fertilizing_interval_days: 30
    )
    water = consumable_items(:water)
    ConsumptionEvent.create!(
      care_subject: plant,
      consumable_item: water,
      quantity: 200,
      unit: "ml",
      occurred_at: 8.days.ago
    )

    plant.update_care_status!

    plant.reload
    assert_equal false, plant.watered_ok
  end

  test "update_care_status! keeps watered_ok true when last water consumption within interval" do
    plant = plants(:one)
    plant.update!(watering_interval_days: 7, fertilizing_interval_days: 30, watered_ok: false)

    travel_to 1.day.from_now do
      plant.update_care_status!
    end

    plant.reload
    assert_equal true, plant.watered_ok
  end

  test "update_care_status! sets fertilized_ok to false when no fertilizing consumption" do
    plant = Plant.create!(
      name: "No fertilizing",
      user: users(:one),
      watering_interval_days: 7,
      fertilizing_interval_days: 30,
      watered_ok: true,
      fertilized_ok: true
    )
    water = consumable_items(:water)
    ConsumptionEvent.create!(
      care_subject: plant,
      consumable_item: water,
      quantity: 200,
      unit: "ml",
      occurred_at: 1.day.ago
    )

    plant.update_care_status!

    plant.reload
    assert_equal true, plant.watered_ok
    assert_equal false, plant.fertilized_ok
  end

  test "update_care_status! sets both when watered and fertilized up to date" do
    plant = plants(:one)
    plant.update!(
      watering_interval_days: 7,
      fertilizing_interval_days: 30,
      watered_ok: false,
      fertilized_ok: false
    )

    plant.update_care_status!

    plant.reload
    assert_equal true, plant.watered_ok
    assert_equal true, plant.fertilized_ok
    assert plant.last_checked_at.present?
  end

  test "update_care_status! does not update when status unchanged" do
    plant = plants(:one)
    plant.update!(
      watering_interval_days: 7,
      fertilizing_interval_days: 30,
      watered_ok: true,
      fertilized_ok: true,
      last_checked_at: 1.hour.ago
    )

    assert_no_changes -> { [ plant.reload.watered_ok, plant.fertilized_ok, plant.last_checked_at ] } do
      plant.update_care_status!
    end
  end
end
