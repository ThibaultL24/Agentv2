# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_13_140224) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "badge_useds", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.integer "nftId"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_badge_useds_on_match_id"
    t.index ["nftId"], name: "index_badge_useds_on_nftId"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name"
    t.string "gameName"
    t.boolean "onChain"
    t.float "price"
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_currencies_on_game_id"
  end

  create_table "currency_packs", force: :cascade do |t|
    t.bigint "currency_id", null: false
    t.integer "currencyNumber"
    t.float "price"
    t.float "unitPrice"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_currency_packs_on_currency_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_crafting", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "unitToCraft"
    t.integer "flexCraft"
    t.integer "sponsorMarkCraft"
    t.integer "nbLowerBadgeToCraft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_crafting_on_item_id"
  end

  create_table "item_farming", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.float "efficiency"
    t.float "ratio"
    t.integer "inGameTime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_farming_on_item_id"
  end

  create_table "item_recharge", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "maxEnergyRecharge"
    t.integer "timeToCHarge"
    t.integer "flexCharge"
    t.integer "sponsorMarkCharge"
    t.float "unitChargeCost"
    t.float "maxChargeCost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_recharge_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "rarity"
    t.string "type"
    t.string "name"
    t.float "efficiency"
    t.integer "nfts"
    t.integer "supply"
    t.float "floorPrice"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "type_id"
    t.bigint "rarity_id"
    t.index ["rarity_id"], name: "index_items_on_rarity_id"
    t.index ["type_id"], name: "index_items_on_type_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "build"
    t.datetime "date"
    t.string "map"
    t.integer "totalFee"
    t.float "feeCost"
    t.integer "slots"
    t.float "luckrate"
    t.integer "time"
    t.integer "energyUsed"
    t.float "energyCost"
    t.integer "totalToken"
    t.float "tokenValue"
    t.integer "totalPremiumCurrency"
    t.float "premiumCurrencyValue"
    t.float "profit"
    t.float "bonusMultiplier"
    t.float "perksMultiplier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_matches_on_user_id"
  end

  create_table "nfts", force: :cascade do |t|
    t.integer "issueId"
    t.integer "itemId"
    t.string "owner"
    t.float "purchasePrice"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itemId"], name: "index_nfts_on_itemId"
  end

  create_table "player_cycles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "playerCycleType"
    t.string "cycleName"
    t.integer "nbBadge"
    t.string "minimumBadgeRarity"
    t.datetime "startDate"
    t.datetime "endDate"
    t.integer "nbDateRepeat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_player_cycles_on_user_id"
  end

  create_table "rarities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "slots", force: :cascade do |t|
    t.bigint "currency_id", null: false
    t.bigint "game_id", null: false
    t.integer "unlockCurrencyNumber"
    t.float "unlockPrice"
    t.boolean "unlocked"
    t.float "totalCost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_slots_on_currency_id"
    t.index ["game_id"], name: "index_slots_on_game_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_builds", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "buildName"
    t.float "bonusMultiplier"
    t.float "perksMultiplier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_builds_on_user_id"
  end

  create_table "user_recharges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "discountTime"
    t.integer "discountNumber"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_recharges_on_user_id"
  end

  create_table "user_slots", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "slot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slot_id"], name: "index_user_slots_on_slot_id"
    t.index ["user_id"], name: "index_user_slots_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "openLootID"
    t.boolean "isPremium"
    t.integer "level"
    t.float "experience"
    t.string "assetType"
    t.string "asset"
    t.integer "slotUnlockedId"
    t.string "maxRarity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "badge_useds", "matches"
  add_foreign_key "badge_useds", "nfts", column: "nftId"
  add_foreign_key "currencies", "games"
  add_foreign_key "currency_packs", "currencies"
  add_foreign_key "item_crafting", "items"
  add_foreign_key "item_farming", "items"
  add_foreign_key "item_recharge", "items"
  add_foreign_key "items", "rarities"
  add_foreign_key "items", "types"
  add_foreign_key "matches", "users"
  add_foreign_key "nfts", "items", column: "itemId"
  add_foreign_key "player_cycles", "users"
  add_foreign_key "slots", "currencies"
  add_foreign_key "slots", "games"
  add_foreign_key "user_builds", "users"
  add_foreign_key "user_recharges", "users"
  add_foreign_key "user_slots", "slots"
  add_foreign_key "user_slots", "users"
end
