module DataLab
  module Constants
    RARITY_ORDER = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exalted", "Exotic", "Transcendent", "Unique"]

    # Taux de conversion
    FLEX_TO_USD = 0.0077
    BFT_TO_USD = 0.01
    SM_TO_USD = 0.01

    # Constantes de base du jeu
    PACK_PRICE = 80.00
    SLOTS_UNLOCK_COST = 508.03
    MATCHES_PER_CHARGE = 18
    CHARGES_PER_BADGE = 3
    FLEX_COST_PER_CHARGE = 1800
    BFT_PER_CHARGE = 1800

    # Sponsor Marks rewards
    SPONSOR_MARKS = {
      "Common" => 26,
      "Uncommon" => 80,
      "Rare" => 250,
      "Epic" => 760,
      "Legendary" => 2300,
      "Mythic" => 7200,
      "Exalted" => 3200,
      "Exotic" => 10000,
      "Transcendent" => 31400,
      "Unique" => 97400
    }

    # Badge related constants
    BADGE_SUPPLY = {
      "Common" => 200_000,
      "Uncommon" => 100_000,
      "Rare" => 50_000,
      "Epic" => 25_000,
      "Legendary" => 10_000,
      "Mythic" => 5_000,
      "Exalted" => 2_000,
      "Exotic" => 500,
      "Transcendent" => 100,
      "Unique" => 1
    }

    BASE_EFFICIENCY = {
      "Common" => 0.1,
      "Uncommon" => 0.205,
      "Rare" => 0.420,
      "Epic" => 1.292,
      "Legendary" => 3.974,
      "Mythic" => 12.219,
      "Exalted" => 375.74,
      "Exotic" => 154.054,
      "Transcendent" => 631.620,
      "Unique" => 2589.642
    }

    BADGE_RATIOS = {
      "Common" => 1.00,
      "Uncommon" => 2.05,
      "Rare" => 2.15,
      "Epic" => 8.72,
      "Legendary" => 26.82,
      "Mythic" => 82.42,
      "Exalted" => 253.55,
      "Exotic" => 1164.8,
      "Transcendent" => 4775.66,
      "Unique" => 19580.22
    }

    MAX_ENERGY = {
      "Common" => 1,
      "Uncommon" => 2,
      "Rare" => 3,
      "Epic" => 4,
      "Legendary" => 5,
      "Mythic" => 6,
      "Exalted" => 7,
      "Exotic" => 8,
      "Transcendent" => 9,
      "Unique" => 10
    }

    RECHARGE_TIMES = {
      "Common" => "8h00",
      "Uncommon" => "7h45",
      "Rare" => "7h30",
      "Epic" => "7h15",
      "Legendary" => "7h00",
      "Mythic" => "6h45",
      "Exalted" => "6h30",
      "Exotic" => "6h15",
      "Transcendent" => "6h00",
      "Unique" => "5h45"
    }

    BFT_PER_MINUTE = {
      "Common" => 15,
      "Uncommon" => 50,
      "Rare" => 120,
      "Epic" => 350,
      "Legendary" => 1000,
      "Mythic" => 2500,
      "Exalted" => 5000,
      "Exotic" => 10000,
      "Transcendent" => 25000,
      "Unique" => 50000
    }

    BADGE_NAMES = {
      "Common" => "Rookie",
      "Uncommon" => "Initiate",
      "Rare" => "Encore",
      "Epic" => "Contender",
      "Legendary" => "Challenger",
      "Mythic" => "Veteran",
      "Exalted" => "Champion",
      "Exotic" => "Olympian",
      "Transcendent" => "Prodigy",
      "Unique" => "MVP"
    }

    # Slots related constants
    SLOT_COSTS = {
      1 => 7000,
      2 => 13000,
      3 => 20000,
      4 => 26000,
      5 => 66000
    }

    SLOT_BONUS_PERCENTAGES = {
      1 => 10,
      2 => 15,
      3 => 20,
      4 => 25,
      5 => 30
    }

    SLOT_MULTIPLIERS = {
      1 => 1.1,
      2 => 1.25,
      3 => 1.45,
      4 => 1.7,
      5 => 2.0
    }

    SLOT_BONUS_VALUES = {
      1 => 0.5,
      2 => 0.75,
      3 => 1.0,
      4 => 1.25,
      5 => 1.5
    }

    CHARGES_ROI = {
      1 => { multiplier_1: 1.1, multiplier_2: 1.2, multiplier_3: 1.3 },
      2 => { multiplier_1: 1.2, multiplier_2: 1.3, multiplier_3: 1.4 },
      3 => { multiplier_1: 1.3, multiplier_2: 1.4, multiplier_3: 1.5 },
      4 => { multiplier_1: 1.4, multiplier_2: 1.5, multiplier_3: 1.6 },
      5 => { multiplier_1: 1.5, multiplier_2: 1.6, multiplier_3: 1.7 }
    }

    # Temps et cycles
    BADGE_RECHARGE_TIME = "7h30"
    CYCLE_6H_BFT_PER_DAY = 19_980
    CYCLE_3H_BFT_PER_DAY = 9_990

    # Coûts et profits
    MATCH_FEE = 0.77
    CHARGE_FEE = 13.86
    RARE_BADGE_RECHARGE_COST = 161.65
    EPIC_BADGE_CRAFT_FLEX = 1975
    EPIC_BADGE_CRAFT_TIME = "5d"
    FULL_RECHARGE_FLEX = 4200
    FULL_RECHARGE_COST = 10.78

    # Profits par cycle
    CYCLE_6H_MONTHLY_PROFIT = 1360.68
    CYCLE_3H_MONTHLY_PROFIT = 728.94
    CYCLE_2D_MONTHLY_PROFIT = 1822.34

    # ROI en jours
    CYCLE_6H_ROI_DAYS = 12.10
    CYCLE_3H_ROI_DAYS = 24.20
    CYCLE_2D_ROI_DAYS = 9.68

    # Méthodes utilitaires communes
    module Utils
      def format_currency(amount)
        return "???" if amount.nil? || amount == "???"
        "$#{'%.2f' % amount}"
      end

      def convert_time_to_minutes(time_str)
        return "???" if time_str == "???"
        hours, minutes = time_str.match(/(\d+)h(\d+)?/).captures
        hours.to_i * 60 + (minutes || "0").to_i
      end

      def calculate_total_cost(flex_amount, sm_amount)
        flex_cost = flex_amount * FLEX_TO_USD
        sm_cost = sm_amount * SM_TO_USD
        (flex_cost + sm_cost).round(2)
      end
    end

    # Méthodes de calcul communes
    module Calculator
      extend self

      def calculate_recharge_cost(rarity)
        flex_cost = case rarity
        when "Common" then 500
        when "Uncommon" then 1400
        when "Rare" then 2520
        when "Epic" then 4800
        when "Legendary" then 12000
        when "Mythic" then 21000
        else 0
        end

        sm_cost = case rarity
        when "Common" then 150
        when "Uncommon" then 350
        when "Rare" then 1023
        when "Epic" then 1980
        when "Legendary" then 4065
        when "Mythic" then 8136
        else 0
        end

        total_usd = (flex_cost * FLEX_TO_USD + sm_cost * SM_TO_USD).round(2)

        {
          flex: flex_cost,
          sm: sm_cost,
          total_usd: total_usd
        }
      end

      def calculate_hourly_bft(rarity)
        base_bft = BFT_PER_MINUTE[rarity] || 0
        base_bft * 60
      end

      def calculate_daily_profit(rarity, level = 1)
        hourly_bft = calculate_hourly_bft(rarity)
        recharge_cost = calculate_recharge_cost(rarity)
        hours_per_charge = 3

        daily_bft = (24 / hours_per_charge) * hourly_bft * hours_per_charge
        daily_cost = (24 / hours_per_charge) * recharge_cost[:total_usd]
        daily_profit = (daily_bft * BFT_TO_USD) - daily_cost

        {
          bft: daily_bft,
          cost: daily_cost,
          profit: daily_profit
        }
      end
    end
  end
end
