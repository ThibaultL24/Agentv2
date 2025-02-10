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
          nb_badges_required_for_craft: contract.item_crafting&.nb_lower_badge_to_craft || 0,
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
      rarity_index = RARITY_ORDER.index(contract.rarity.name)
      return 0 if rarity_index.nil?
      (rarity_index + 1) * 10
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
      base_flex_cost = 130  # Coût de base pour Common
      rarity_multiplier = get_rarity_multiplier(contract.rarity.name)
      (base_flex_cost * rarity_multiplier).round(0)
    end

    def calculate_sp_marks_charge(contract)
      flex_cost = calculate_flex_charge(contract)
      return "???" if flex_cost == "???"
      (flex_cost * 2.23).round(0)  # Ratio moyen Sponsor Marks/FLEX
    end

    def calculate_sp_marks_craft(contract)
      base_marks = 2400  # Coût de base pour Uncommon
      return 0 if contract.rarity.name == "Common"

      rarity_multiplier = get_rarity_multiplier(contract.rarity.name)
      badges_required = contract.item_crafting&.nb_lower_badge_to_craft || 0
      (base_marks * rarity_multiplier * (1 + badges_required * 0.1)).round(0)
    end

    def calculate_flex_craft(contract)
      base_flex = 1320  # Coût de base pour Common
      rarity_multiplier = get_rarity_multiplier(contract.rarity.name)
      floor_price_factor = contract.floorPrice ? Math.log10(contract.floorPrice) : 1

      (base_flex * rarity_multiplier * floor_price_factor).round(0)
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
      sp_marks = calculate_sp_marks_for_level(level)
      return 0 if sp_marks == 0
      (sp_marks * 0.01).round(2)  # Conversion Sponsor Marks en USD
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
      when "Exotic" then 216 * 60
      when "Transcendent" then 240 * 60
      when "Unique" then 264 * 60
      end
    end

    def get_rarity_multiplier(rarity_name)
      rarity_index = RARITY_ORDER.index(rarity_name)
      return 1 if rarity_index.nil?
      (1.5 ** rarity_index).round(2)
    end
  end
end
