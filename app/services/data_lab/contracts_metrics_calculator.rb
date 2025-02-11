module DataLab
  class ContractsMetricsCalculator
    include Constants::Utils
    include Constants::Calculator

    # Données fixes uniquement pour les levels 1, 5 et 10
    FIXED_LEVEL_DATA = {
      1 => { sp_marks: 420, cost: 3.2329 },
      5 => { sp_marks: 2174, cost: 16.7343 },
      10 => { sp_marks: 4545, cost: 34.9850 }
    }.freeze

    def initialize(user)
      @user = user
    end

    def calculate
      contracts = load_contracts
      {
        contracts: calculate_contracts_cost(contracts),
        level_up: calculate_level_up_costs
      }
    end

    private

    def load_contracts
      Item.includes(:type, :rarity, :item_crafting, :item_farming, :item_recharge)
          .joins(:rarity)
          .where(types: { name: 'Contract' })
          .sort_by { |contract| Constants::RARITY_ORDER.index(contract.rarity.name) }
    end

    def calculate_contracts_cost(contracts)
      contracts.map do |contract|
        rarity = contract.rarity.name
        {
          "1. rarity": rarity,
          "2. item": Constants::CONTRACT_NAMES[rarity],
          "3. supply": Constants::CONTRACT_SUPPLY[rarity],
          "4. floor_price": format_currency(contract.floorPrice),
          "5. lvl_max": Constants::CONTRACT_MAX_LEVELS[rarity],
          "6. max_energy": Constants::CONTRACT_MAX_ENERGY[rarity],
          "7. time_to_craft": format_hours(calculate_craft_time(rarity)),
          "8. nb_badges_required": contract.item_crafting&.nb_lower_badge_to_craft || 0,
          "9. flex_craft": calculate_flex_craft(contract),
          "10. sp_marks_craft": calculate_sp_marks_craft(contract),
          "11. time_to_charge": format_time_to_charge(rarity),
          "12. flex_charge": calculate_flex_charge(rarity),
          "13. sp_marks_charge": calculate_sp_marks_charge(rarity)
        }
      end
    end

    def calculate_level_up_costs
      (1..15).map do |level|
        if Constants::CONTRACT_LEVEL_DATA.key?(level)
          data = Constants::CONTRACT_LEVEL_DATA[level]
          {
            "1. level": level,
            "2. sp_marks_nb": data[:sp_marks],
            "3. sp_marks_cost": format_currency(data[:sp_marks] * Constants::SM_TO_USD),
            "4. total_cost": format_currency(data[:total_cost])
          }
        else
          {
            "1. level": level,
            "2. sp_marks_nb": nil,
            "3. sp_marks_cost": "???",
            "4. total_cost": "???"
          }
        end
      end
    end

    def calculate_craft_time(rarity)
      base_time = Constants::CONTRACT_BASE_CRAFT_TIME
      rarity_index = Constants::RARITY_ORDER.index(rarity) || 0
      base_time + (rarity_index * Constants::CONTRACT_CRAFT_TIME_INCREMENT)
    end

    def format_time_to_charge(rarity)
      base_time = Constants::CONTRACT_BASE_RECHARGE_TIME
      rarity_index = Constants::RARITY_ORDER.index(rarity) || 0
      reduction = rarity_index * Constants::CONTRACT_RECHARGE_TIME_REDUCTION

      hours = (base_time - reduction) / 60
      minutes = (base_time - reduction) % 60
      "%dh%02d" % [hours, minutes]
    end

    def calculate_flex_charge(rarity)
      return Constants::FLEX_COST_PER_CHARGE if rarity == "Rare"

      base_cost = Constants::FLEX_COST_PER_CHARGE
      multiplier = Constants::CONTRACT_RARITY_MULTIPLIERS[rarity] || 1
      (base_cost * multiplier).round(0)
    end

    def calculate_sp_marks_charge(rarity)
      flex_cost = calculate_flex_charge(rarity)
      (flex_cost * Constants::CONTRACT_SP_MARKS_MULTIPLIER).round(0)
    end

    def calculate_flex_craft(contract)
      rarity = contract.rarity.name
      base_flex = Constants::CONTRACT_BASE_FLEX_CRAFT
      multiplier = Constants::CONTRACT_RARITY_MULTIPLIERS[rarity] || 1
      floor_price_factor = contract.floorPrice ? Math.log10(contract.floorPrice) : 1

      (base_flex * multiplier * floor_price_factor).round(0)
    end

    def calculate_sp_marks_craft(contract)
      rarity = contract.rarity.name
      return 0 if rarity == "Common"
      return Constants::EPIC_BADGE_CRAFT_FLEX if rarity == "Epic"

      base_marks = Constants::CONTRACT_BASE_SP_MARKS_CRAFT
      multiplier = Constants::CONTRACT_RARITY_MULTIPLIERS[rarity] || 1
      badges_required = contract.item_crafting&.nb_lower_badge_to_craft || 0

      (base_marks * multiplier * (1 + badges_required * 0.1)).round(0)
    end

    def format_hours(minutes)
      hours = minutes / 60
      "#{hours}h"
    end
  end
end
