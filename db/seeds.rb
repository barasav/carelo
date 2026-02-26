# Run with: bin/rails db:seed

user = User.create!(
  email: "demo@example.com",
  password: "password123",
  password_confirmation: "password123"
)

# Consumable items
water = user.consumable_items.find_or_create_by!(name: "Water", category: "water") do |item|
  item.default_unit = "ml"
end

fertilizer = user.consumable_items.find_or_create_by!(name: "BioBizz fertilizer", category: "fertilizer") do |item|
  item.default_unit = "ml"
end

universal_fertilizer = user.consumable_items.find_or_create_by!(name: "Univerzální hnojivo", category: "fertilizer") do |item|
  item.default_unit = "ml"
end

orchid_food = user.consumable_items.find_or_create_by!(name: "Orchidejní hnojivo", category: "fertilizer") do |item|
  item.default_unit = "ml"
end

cat_food = user.consumable_items.find_or_create_by!(name: "Acana cat food", category: "food") do |item|
  item.default_unit = "g"
end

dog_food = user.consumable_items.find_or_create_by!(name: "Royal Canin", category: "food") do |item|
  item.default_unit = "g"
end

horse_feed = user.consumable_items.find_or_create_by!(name: "Oves", category: "food") do |item|
  item.default_unit = "kg"
end

bird_seed = user.consumable_items.find_or_create_by!(name: "Krmná směs pro ptáky", category: "food") do |item|
  item.default_unit = "g"
end

fish_flakes = user.consumable_items.find_or_create_by!(name: "Vločky pro ryby", category: "food") do |item|
  item.default_unit = "g"
end

vitamins = user.consumable_items.find_or_create_by!(name: "Vitamíny pro psy", category: "supplement") do |item|
  item.default_unit = "g"
end

# Plants
plant1 = user.plants.create!(
  name: "Fíkus",
  location: "Obývák",
  light: "rozptýlené",
  watering_amount: 200,
  watering_interval_days: 7,
  fertilizing_interval_days: 30,
  fertilizer_type: "univerzální",
  fertilizer_amount: 5
)

plant2 = user.plants.create!(
  name: "Monstera",
  location: "Ložnice",
  light: "polostín",
  watering_interval_days: 4,
  fertilizing_interval_days: 14
)

plant3 = user.plants.create!(
  name: "Aloe vera",
  location: "Kuchyň",
  light: "přímé slunce",
  watering_amount: 100,
  watering_interval_days: 14,
  fertilizing_interval_days: 60
)

plant4 = user.plants.create!(
  name: "Orchidej",
  location: "Obývák",
  light: "rozptýlené",
  watering_amount: 150,
  watering_interval_days: 7,
  fertilizing_interval_days: 14,
  fertilizer_type: "orchidejní"
)

plant5 = user.plants.create!(
  name: "Kaktus",
  location: "Okno",
  light: "přímé slunce",
  watering_amount: 50,
  watering_interval_days: 21
)

plant6 = user.plants.create!(
  name: "Břečťan",
  location: "Ložnice",
  light: "polostín",
  watering_interval_days: 5,
  fertilizing_interval_days: 28
)

plant7 = user.plants.create!(
  name: "Tchynin jazyk",
  location: "Koupelna",
  light: "stín",
  watering_interval_days: 10,
  fertilizing_interval_days: 30
)

# Consumption events for plants
ConsumptionEvent.create!(
  care_subject: plant1,
  consumable_item: water,
  quantity: 200,
  unit: "ml",
  occurred_at: 2.days.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: plant1,
  consumable_item: fertilizer,
  quantity: 5,
  unit: "ml",
  occurred_at: 3.days.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: plant2,
  consumable_item: water,
  quantity: 300,
  unit: "ml",
  occurred_at: 1.day.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: plant3,
  consumable_item: water,
  quantity: 100,
  unit: "ml",
  occurred_at: 5.days.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: plant4,
  consumable_item: water,
  quantity: 150,
  unit: "ml",
  occurred_at: 3.days.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: plant4,
  consumable_item: orchid_food,
  quantity: 3,
  unit: "ml",
  occurred_at: 1.week.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: plant6,
  consumable_item: water,
  quantity: 150,
  unit: "ml",
  occurred_at: 4.days.ago,
  source: "manual"
)

# Animals
cat = user.animals.create!(name: "Mňau", species: "cat")
horse = user.animals.create!(name: "Hřebec", species: "horse")
dog = user.animals.create!(name: "Rex", species: "dog")
bird = user.animals.create!(name: "Pípo", species: "bird")

# Consumption events for animals
ConsumptionEvent.create!(
  care_subject: cat,
  consumable_item: cat_food,
  quantity: 80,
  unit: "g",
  occurred_at: 1.day.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: horse,
  consumable_item: horse_feed,
  quantity: 4,
  unit: "kg",
  occurred_at: 1.day.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: dog,
  consumable_item: dog_food,
  quantity: 250,
  unit: "g",
  occurred_at: 2.days.ago,
  source: "manual"
)

ConsumptionEvent.create!(
  care_subject: bird,
  consumable_item: bird_seed,
  quantity: 20,
  unit: "g",
  occurred_at: 1.day.ago,
  source: "manual"
)

# Stock lots
user.stock_lots.create!(
  consumable_item: cat_food,
  quantity: 5000,
  unit: "g",
  purchased_on: 2.weeks.ago.to_date
)

user.stock_lots.create!(
  consumable_item: dog_food,
  quantity: 15000,
  unit: "g",
  purchased_on: 1.week.ago.to_date
)

user.stock_lots.create!(
  consumable_item: horse_feed,
  quantity: 50,
  unit: "kg",
  purchased_on: 3.days.ago.to_date
)

user.stock_lots.create!(
  consumable_item: water,
  quantity: 5,
  unit: "l",
  purchased_on: 1.month.ago.to_date
)

user.stock_lots.create!(
  consumable_item: fertilizer,
  quantity: 1,
  unit: "l",
  purchased_on: 2.weeks.ago.to_date
)

# Consumption rules for plants
plant1.consumption_rules.create!(
  consumable_item: water,
  amount: 200,
  unit: "ml",
  period: "day",
  active: true,
  kind: "watering"
)

plant1.consumption_rules.create!(
  consumable_item: fertilizer,
  amount: 5,
  unit: "ml",
  period: "month",
  active: true,
  kind: "fertilizing"
)

plant2.consumption_rules.create!(
  consumable_item: water,
  amount: 300,
  unit: "ml",
  period: "day",
  active: true,
  kind: "watering"
)

plant4.consumption_rules.create!(
  consumable_item: water,
  amount: 150,
  unit: "ml",
  period: "day",
  active: true,
  kind: "watering"
)

plant4.consumption_rules.create!(
  consumable_item: orchid_food,
  amount: 3,
  unit: "ml",
  period: "week",
  active: true,
  kind: "fertilizing"
)

# Consumption rules for animals
cat.consumption_rules.create!(
  consumable_item: cat_food,
  amount: 100,
  unit: "g",
  period: "day",
  active: true,
  kind: "feeding"
)

horse.consumption_rules.create!(
  consumable_item: horse_feed,
  amount: 4,
  unit: "kg",
  period: "day",
  active: true,
  kind: "feeding"
)

dog.consumption_rules.create!(
  consumable_item: dog_food,
  amount: 250,
  unit: "g",
  period: "day",
  active: true,
  kind: "feeding"
)

dog.consumption_rules.create!(
  consumable_item: vitamins,
  amount: 5,
  unit: "g",
  period: "day",
  active: true,
  kind: "feeding"
)

bird.consumption_rules.create!(
  consumable_item: bird_seed,
  amount: 20,
  unit: "g",
  period: "day",
  active: true,
  kind: "feeding"
)

puts "Seed completed. Demo user: demo@example.com / password123"
