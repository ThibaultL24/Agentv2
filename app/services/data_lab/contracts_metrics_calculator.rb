module DataLab
  class ContractsMetricsCalculator
    RARITY_ORDER = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exalted", "Exotic", "Transcendent", "Unique"]

    def initialize(user)
      @user = user
    end

    def calculate
      contracts = Item.includes(:type, :rarity, :item_crafting, :item_farming, :item_recharge)
                     .joins(:rarity)
                     .where(types: { name: 'Contract' })
                     .sort_by { |contract| RARITY_ORDER.index(contract.rarity.name) }

      {
        contracts_cost: calculate_contracts_cost(contracts),
        level_up_costs: calculate_level_up_costs
      }
    end

    private

    def calculate_contracts_cost(contracts)
      contracts.map do |contract|
        {
          rarity: contract.rarity.name,
          item: contract.name,
          supply: contract.supply,
          floor_price: format_currency(contract.floorPrice),
          lvl_max: calculate_max_level(contract),
          max_energy_recharge: calculate_max_energy(contract),
          time_to_craft: format_hours(get_craft_time(contract)),
          nb_badges_rarity_minus_one: contract.item_crafting&.nb_lower_badge_to_craft || 0,
          flex_craft: calculate_flex_craft(contract),
          sp_marks_craft: calculate_sp_marks_craft(contract),
          time_to_charge: format_time_to_charge(contract),
          flex_charge: calculate_flex_charge(contract),
          sp_marks_charge: calculate_sp_marks_charge(contract)
        }
      end
    end

    def calculate_level_up_costs
      (1..4).map do |level|
        {
          level: level,
          sp_marks_nb: calculate_sp_marks_for_level(level),
          sp_marks_cost: format_currency(calculate_sp_marks_cost_for_level(level)),
          total_cost: format_currency(calculate_total_cost_for_level(level))
        }
      end
    end

    def calculate_max_level(contract)
      case contract.rarity.name
      when "Common" then 10
      when "Uncommon" then 20
      when "Rare" then 30
      when "Epic" then 40
      when "Legendary" then 50
      when "Mythic" then 60
      when "Exalted" then 70
      when "Exotic" then 80
      when "Transcendent" then 90
      when "Unique" then 100
      end
    end

    def calculate_max_energy(contract)
      case contract.rarity.name
      when "Common" then 1
      when "Uncommon" then 2
      when "Rare" then 3
      when "Epic" then 4
      when "Legendary" then 5
      when "Mythic" then 6
      when "Exalted" then 7
      when "Exotic" then 8
      when "Transcendent" then 9
      when "Unique" then 10
      end
    end

    def format_hours(minutes)
      hours = minutes / 60
      "#{hours}h"
    end

    def format_time_to_charge(contract)
      case contract.rarity.name
      when "Common" then "8h00"
      when "Uncommon" then "7h45"
      when "Rare" then "7h30"
      when "Epic" then "7h15"
      when "Legendary" then "7h00"
      when "Mythic" then "6h45"
      when "Exalted" then "6h30"
      when "Exotic" then "6h15"
      when "Transcendent" then "6h00"
      when "Unique" then "5h45"
      end
    end

    def calculate_flex_charge(contract)
      case contract.rarity.name
      when "Common" then 130
      when "Uncommon" then 440
      when "Rare" then 1_662
      when "Epic" then 5_852
      when "Legendary" then 19_665
      when "Mythic" then 57_948
      else "???"
      end
    end

    def calculate_sp_marks_charge(contract)
      case contract.rarity.name
      when "Common" then 290
      when "Uncommon" then 960
      when "Rare" then 2_943
      when "Epic" then 10_340
      when "Legendary" then 34_770
      when "Mythic" then 300_642
      else "???"
      end
    end

    def calculate_sp_marks_craft(contract)
      case contract.rarity.name
      when "Common" then 0
      when "Uncommon" then 2_400
      when "Rare" then 4_100
      when "Epic" then 10_927
      when "Legendary" then 21_700
      when "Mythic" then 60_500
      when "Exalted" then 219_946
      else "???"
      end
    end

    def calculate_flex_craft(contract)
      case contract.rarity.name
      when "Common" then 1_320
      when "Uncommon" then 293
      when "Rare" then 1_356
      when "Epic" then 25_900
      when "Legendary" then 99_400
      when "Mythic" then 368_192
      else "???"
      end
    end

    def calculate_sp_marks_for_level(level)
      case level
      when 1 then 420
      when 2 then 181
      when 3 then 250
      when 4 then 350
      end
    end

    def calculate_sp_marks_cost_for_level(level)
      case level
      when 1 then 0.65
      when 2 then 1.39
      when 3 then 1.92
      when 4 then 2.70
      end
    end

    def calculate_total_cost_for_level(level)
      case level
      when 1 then 0.65
      when 2 then 2.04
      when 3 then 3.96
      when 4 then 6.66
      end
    end

    def format_currency(amount)
      return "???" if amount.nil?
      "$#{'%.2f' % amount}"
    end

    def get_craft_time(contract)
      case contract.rarity.name
      when "Common" then 48 * 60
      when "Uncommon" then 72 * 60
      when "Rare" then 96 * 60
      when "Epic" then 120 * 60
      when "Legendary" then 144 * 60
      when "Mythic" then 168 * 60
      when "Exalted" then 192 * 60
      else 48 * 60
      end
    end
  end
end
