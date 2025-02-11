module DataLab
  class CraftMetricsCalculator
    include Constants::Utils
    include Constants::Calculator

    def initialize(user)
      @user = user
      @badges = load_badges
    end

    def calculate
      @badges.map do |badge|
        rarity = badge.rarity.name
        {
          "1. rarity": rarity,
          "2. supply": badge.supply,
          "3. nb_previous_rarity_item": calculate_previous_rarity_needed(rarity),
          "4. flex_craft": calculate_flex_craft_cost(rarity),
          "5. flex_craft_cost": format_currency(calculate_flex_craft_cost(rarity) * Constants::FLEX_TO_USD),
          "6. sp_marks_craft": calculate_sp_marks_craft_cost(rarity),
          "7. sp_marks_value": format_currency(calculate_sp_marks_craft_cost(rarity) * Constants::SM_TO_USD),
          "8. craft_time": format_hours(calculate_craft_time(rarity)),
          "9. total_craft_cost": format_currency(calculate_total_craft_cost(rarity))
        }
      end
    end

    private

    def load_badges
      Item.includes(:type, :rarity, :item_crafting, :item_farming, :item_recharge)
          .joins(:rarity)
          .where(types: { name: 'Badge' })
          .sort_by { |badge| Constants::RARITY_ORDER.index(badge.rarity.name) }
    end

    def calculate_previous_rarity_needed(rarity)
      # D'après le notepad
      case rarity
      when "Common" then 0
      when "Uncommon", "Rare" then 2
      when "Epic", "Legendary", "Mythic", "Exalted" then 3
      when "Exotic", "Transcendent", "Unique" then 4
      else 0
      end
    end

    def calculate_flex_craft_cost(rarity)
      # D'après le notepad
      case rarity
      when "Common" then 1300
      when "Uncommon" then 290
      when "Rare" then 1400
      when "Epic" then 6300
      when "Legendary" then 25600
      when "Mythic" then 92700
      when "Exalted" then 368192
      when "Exotic" then 3875
      when "Transcendent" then 4350
      when "Unique" then 4825
      else 0
      end
    end

    def calculate_sp_marks_craft_cost(rarity)
      # D'après le notepad
      case rarity
      when "Common" then 0
      when "Uncommon" then 3967
      when "Rare" then 6616
      when "Epic" then 16556
      when "Legendary" then 27618
      when "Mythic" then 28222
      when "Exalted" then 219946
      when "Exotic" then 800
      when "Transcendent" then 900
      when "Unique" then 1000
      else 0
      end
    end

    def calculate_craft_time(rarity)
      # D'après le notepad, temps en heures
      case rarity
      when "Common" then 120
      when "Uncommon" then 180
      when "Rare" then 240
      when "Epic" then 300
      when "Legendary" then 360
      when "Mythic" then 420
      when "Exalted" then 480
      else 0
      end
    end

    def calculate_total_craft_cost(rarity)
      flex_cost = calculate_flex_craft_cost(rarity) * Constants::FLEX_TO_USD
      sp_marks_cost = calculate_sp_marks_craft_cost(rarity) * Constants::SM_TO_USD
      flex_cost + sp_marks_cost
    end

    def format_hours(hours)
      "#{hours}h"
    end

    def format_currency(amount)
      return nil if amount.nil?
      "$#{amount}"
    end
  end
end
