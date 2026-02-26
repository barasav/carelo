require "test_helper"

class PlantCareStatusJobTest < ActiveJob::TestCase
  test "updates watered_ok to false when last water consumption exceeds interval" do
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

    PlantCareStatusJob.perform_now

    plant.reload
    assert_equal false, plant.watered_ok
  end

  test "keeps watered_ok true when last water consumption within interval" do
    plant = plants(:one)
    plant.update!(watering_interval_days: 7, fertilizing_interval_days: 30, watered_ok: false)

    travel_to 1.day.from_now do
      PlantCareStatusJob.perform_now
    end

    plant.reload
    assert_equal true, plant.watered_ok
  end

  test "updates fertilized_ok to false when no fertilizing consumption" do
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

    PlantCareStatusJob.perform_now

    plant.reload
    assert_equal true, plant.watered_ok
    assert_equal false, plant.fertilized_ok
  end

  test "updates both when watered and fertilized up to date" do
    plant = plants(:one)
    plant.update!(
      watering_interval_days: 7,
      fertilizing_interval_days: 30,
      watered_ok: false,
      fertilized_ok: false
    )

    PlantCareStatusJob.perform_now

    plant.reload
    assert_equal true, plant.watered_ok
    assert_equal true, plant.fertilized_ok
    assert plant.last_checked_at.present?
  end

  test "does not update when status unchanged" do
    plant = plants(:one)
    plant.update!(
      watering_interval_days: 7,
      fertilizing_interval_days: 30,
      watered_ok: true,
      fertilized_ok: true,
      last_checked_at: 1.hour.ago
    )

    assert_no_changes -> { [ plant.reload.watered_ok, plant.fertilized_ok, plant.last_checked_at ] } do
      PlantCareStatusJob.perform_now
    end
  end
end
