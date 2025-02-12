module DataLab
  module Constants
    # Taux de conversion monétaires (fixes)
    FLEX_TO_USD = 0.0077
    BFT_TO_USD = 0.01
    SM_TO_USD = 0.01

    # Ordre des raretés (fixe)
    RARITY_ORDER = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exalted", "Exotic", "Transcendent", "Unique"]

    # Règles de jeu fixes
    MATCHES_PER_CHARGE = 18
    MINUTES_PER_MATCH = 10
    HOURS_PER_ENERGY = 1

    # Noms des badges (règles de jeu fixes)
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
    end

    # Méthodes de calcul communes
    module Calculator
      extend self

      def calculate_max_energy(rarity)
        return 1 unless rarity && RARITY_ORDER.include?(rarity)
        case rarity
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
        else 1
        end
      end

      def calculate_recharge_time(rarity)
        return "8h00" unless rarity && RARITY_ORDER.include?(rarity)
        case rarity
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
        else "5h30"
        end
      end

      def calculate_bft_per_minute(rarity)
        case rarity
        when "Common" then 15
        when "Uncommon" then 50
        when "Rare" then 120
        when "Epic" then 350
        when "Legendary" then 1000
        when "Mythic" then 2500
        when "Exalted" then 5000
        when "Exotic" then 10000
        when "Transcendent" then 25000
        when "Unique" then 50000
        else 0
        end
      end

      def calculate_recharge_cost(rarity)
        flex_costs = {
          "Common" => 500,
          "Uncommon" => 1400,
          "Rare" => 2520,
          "Epic" => 4800,
          "Legendary" => 12000,
          "Mythic" => 21000,
          "Exalted" => 9800,
          "Exotic" => 11200,
          "Transcendent" => 12600,
          "Unique" => 14000
        }

        sm_costs = {
          "Common" => 150,
          "Uncommon" => 350,
          "Rare" => 1023,
          "Epic" => 1980,
          "Legendary" => 4065,
          "Mythic" => 8136,
          "Exalted" => nil,
          "Exotic" => nil,
          "Transcendent" => nil,
          "Unique" => nil
        }

        flex_cost = flex_costs[rarity]
        sm_cost = sm_costs[rarity]

        return nil if flex_cost.nil? || sm_cost.nil?

        {
          flex: flex_cost,
          sm: sm_cost,
          total_usd: (flex_cost * FLEX_TO_USD + sm_cost * SM_TO_USD).round(2)
        }
      end

      def calculate_bft_value_per_max_charge(rarity)
        bft_per_minute = calculate_bft_per_minute(rarity)
        max_energy = calculate_max_energy(rarity)
        return nil if bft_per_minute.nil? || max_energy.nil?

        minutes_per_energy = 60 # 1 heure par énergie
        total_bft = bft_per_minute * max_energy * minutes_per_energy
        (total_bft * BFT_TO_USD).round(2)
      end

      def calculate_roi(badge, recharge_cost, bft_value_per_max_charge)
        return nil if badge.nil? || recharge_cost.nil? || bft_value_per_max_charge.nil? || bft_value_per_max_charge.zero?

        total_cost = badge.floorPrice.to_f + recharge_cost.to_f
        return nil if total_cost.zero?

        numerator = total_cost + (((total_cost/bft_value_per_max_charge) - 1) * recharge_cost)
        (numerator / bft_value_per_max_charge).round(2)
      end

      def calculate_slot_roi(badge, slots_count, slot_total_cost, recharge_cost, bft_value_per_max_charge)
        return 0 if badge.nil? || slots_count.nil? || slot_total_cost.nil? || recharge_cost.nil? || bft_value_per_max_charge.nil? || bft_value_per_max_charge.zero?

        total_cost = badge.floor_price + recharge_cost
        slots = slots_count + 1

        numerator = slot_total_cost +
                   (total_cost * slots) +
                   ((((total_cost * slots)/bft_value_per_max_charge) - (1 * slots)) * recharge_cost)

        denominator = bft_value_per_max_charge * slots

        (numerator / denominator).round(2)
      end
    end
  end
end
