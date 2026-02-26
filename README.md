# Plantcare

An application for managing plant and animal care – tracking watering, fertilizing, feeding, inventory, and calculating remaining consumable supplies.

## Purpose

Plantcare helps users track:
- **Plants** – watering and fertilizing schedules, amounts, and care status
- **Animals** – feeding rules, daily food consumption, and inventory status
- **Consumable items** (food, fertilizer, water, supplements) – stock levels, lots, and expiry dates
- **Stock lots** – quantity, purchase date, and expiry
- **Consumption rules** – what, how much, how often (day/week/month/event), and for whom

The app automatically calculates days of supply based on daily consumption and alerts when restocking is needed. For plants, it tracks watering and fertilizing status based on the latest consumption events.

## Technology

- **Ruby** 3.4.4
- **Rails** 8.1
- **Database:** MySQL 5.7+
- **Web server:** Puma (Thruster in production)
- **Frontend:** Hotwire (Turbo, Stimulus), propshaft, importmap
- **Authentication:** Devise
- **Background jobs:** Solid Queue
- **Cache:** Solid Cache

## Requirements

- Ruby 3.4.4
- MySQL 5.7 or 8.0+
- Node.js (for asset pipeline)

## Running in Development

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Database:**
   - MySQL must be running locally
   - Edit `config/database.yml` if you need different credentials
   - Run migrations and seed:
   ```bash
   bin/rails db:prepare
   ```

3. **Start the application:**
   ```bash
   bin/dev
   ```
   Or use `bin/setup` for a full setup including dependencies and database (with optional `--skip-server`).

4. **Background jobs (Solid Queue):**
   Runs as a separate process in production. For development, you can start the worker:
   ```bash
   bin/rails solid_queue:start
   ```

## Tests

```bash
bin/rails test
```

MySQL with databases `plantcare_test` and `plantcare_test_queue` is required to run tests.

## Features

### Plants

- Add, edit, and delete plants
- Watering: amount (ml), interval in days
- Fertilizing: fertilizer type, amount, interval in days
- Blooming period (start/end)
- Location and light conditions
- **Care status:** Automatic evaluation of whether the plant is watered/fertilized on time based on the latest consumption event (daily `PlantCareStatusJob`)

### Animals

- Add, edit, and delete animals
- Species: cat, horse, dog, bird
- **Feeding rules (Consumption rules):** food amount, frequency (day/week/month/event), active period
- Feeding status: days of supply left, restock alerts
- Linked to consumable items (food)

### Consumable Items

- Categories: food, fertilizer, water, supplement
- Stock levels and daily consumption
- Days-left calculation based on stock and consumption rules
- "Order needed" indicator
- Linked to feeding/watering/fertilizing rules

### Stock Lots

- Lot tracking: quantity, unit, purchase date, expiry
- Add, edit, and delete lots per item
- Sum of available quantity across lots

### Consumption Rules

- Rule assigns a consumable item to a plant or animal
- Amount, unit, frequency (day/week/month/event)
- Active period: start/end
- Type: feeding, watering, fertilizing

### Restock Alerts

- Automatic alerts for low stock (default threshold 7 days)
- Updated by `InventoryRestockJob` daily at 6:00

### Users (Devise)

- Registration, sign in, sign out
- Password reset
- Each user sees only their own plants, animals, and items
