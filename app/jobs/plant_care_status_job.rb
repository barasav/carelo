class PlantCareStatusJob < ApplicationJob
  queue_as :default

  def perform
    Plant.find_each { |plant| plant.update_care_status! }
  end
end
