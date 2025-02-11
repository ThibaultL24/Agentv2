module DataLab
  class BadgesMetricsCalculator
    include Constants::Utils
    include Constants::Calculator

    RARITY_ORDER = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exalted", "Exotic", "Transcendent", "Unique"]
    BFT_PRICE = 0.01
    FLEX_PRICE = 0.0077

    BADGE_METRICS = {
      "Common" => {
        name: "Rookie",
        supply: 200_000,
        floor_price: 7.99,
        efficiency: 0.1,
        ratio: 1.00,
        max_energy: 1,
        time_to_charge: "8h00",
        in_game_time: "01h00",
        max_charge_cost: 5.35,
        cost_per_hour: 0.89,
        sbft_per_minute: 15,
        sbft_per_max_charge: 900,
        sbft_value: 9.00,
        roi: 1.31
      },
      "Uncommon" => {
        name: "Initiate",
        supply: 100_000,
        floor_price: 28.50,
        efficiency: 0.205,
        ratio: 2.05,
        max_energy: 2,
        time_to_charge: "7h45",
        in_game_time: "02h00",
        max_charge_cost: 14.28,
        cost_per_hour: 1.19,
        sbft_per_minute: 50,
        sbft_per_max_charge: 6000,
        sbft_value: 60.00,
        roi: 3.62
      },
      "Rare" => {
        name: "Encore",
        supply: 50_000,
        floor_price: 82.50,
        efficiency: 0.420,
        ratio: 2.15,
        max_energy: 3,
        time_to_charge: "7h30",
        in_game_time: "03h00",
        max_charge_cost: 34.16,
        cost_per_hour: 1.90,
        sbft_per_minute: 120,
        sbft_per_max_charge: 21600,
        sbft_value: 216.00,
        roi: 4.12
      },
      "Epic" => {
        name: "Contender",
        supply: 25_000,
        floor_price: 410.00,
        efficiency: 1.292,
        ratio: 8.72,
        max_energy: 4,
        time_to_charge: "7h15",
        in_game_time: "04h00",
        max_charge_cost: 68.74,
        cost_per_hour: 2.86,
        sbft_per_minute: 350,
        sbft_per_max_charge: 84000,
        sbft_value: 840.00,
        roi: 4.66
      },
      "Legendary" => {
        name: "Challenger",
        supply: 10_000,
        floor_price: 1000.00,
        efficiency: 3.974,
        ratio: 26.82,
        max_energy: 5,
        time_to_charge: "7h00",
        in_game_time: "05h00",
        max_charge_cost: 133.02,
        cost_per_hour: 14.43,
        sbft_per_minute: 1000,
        sbft_per_max_charge: 300000,
        sbft_value: 3000.00,
        roi: 5.01
      },
      "Mythic" => {
        name: "Veteran",
        supply: 5_000,
        floor_price: 4000.00,
        efficiency: 12.219,
        ratio: 82.42,
        max_energy: 6,
        time_to_charge: "6h45",
        in_game_time: "06h00",
        max_charge_cost: 264.89,
        cost_per_hour: 7.36,
        sbft_per_minute: 2500,
        sbft_per_max_charge: "???",
        sbft_value: "???",
        roi: "???"
      },
      "Exalted" => {
        name: "Champion",
        supply: 1_000,
        floor_price: 100_000.00,
        efficiency: 375.74,
        ratio: 253.55,
        max_energy: 7,
        time_to_charge: "6h30",
        in_game_time: "07h00",
        max_charge_cost: "???",
        cost_per_hour: "???",
        sbft_per_minute: 5000,
        sbft_per_max_charge: "???",
        sbft_value: "???",
        roi: "???"
      },
      "Exotic" => {
        name: "Olympian",
        supply: 250,
        floor_price: 55_000.00,
        efficiency: 154.054,
        ratio: 1164.8,
        max_energy: 8,
        time_to_charge: "6h15",
        in_game_time: "08h00",
        max_charge_cost: "???",
        cost_per_hour: "???",
        sbft_per_minute: 10000,
        sbft_per_max_charge: "???",
        sbft_value: "???",
        roi: "???"
      },
      "Transcendent" => {
        name: "Prodigy",
        supply: 100,
        floor_price: 150000.00,
        efficiency: 631.620,
        ratio: 4775.66,
        max_energy: 9,
        time_to_charge: "6h00",
        in_game_time: "09h00",
        max_charge_cost: "???",
        cost_per_hour: "???",
        sbft_per_minute: 25000,
        sbft_per_max_charge: "???",
        sbft_value: "???",
        roi: "???"
      },
      "Unique" => {
        name: "MVP",
        supply: 1,
        floor_price: 500000.00,
        efficiency: 2589.642,
        ratio: 19580.22,
        max_energy: 10,
        time_to_charge: "5h45",
        in_game_time: "10h00",
        max_charge_cost: "???",
        cost_per_hour: "???",
        sbft_per_minute: 50000,
        sbft_per_max_charge: "???",
        sbft_value: "???",
        roi: "???"
      }
    }.freeze

    def initialize(user)
      @user = user
    end

    def calculate
      badges = load_badges
      {
        badges_metrics: calculate_badges_metrics(badges),
        badges_details: calculate_badges_details(badges)
      }
    end

    private

    def load_badges
      Item.includes(:type, :rarity, :item_farming, :item_recharge, :item_crafting, :nfts)
          .joins(:rarity)
          .where(types: { name: 'Badge' })
          .sort_by { |badge| Constants::RARITY_ORDER.index(badge.rarity.name) }
    end

    def calculate_badges_metrics(badges)
      badges.map do |badge|
        next unless badge&.rarity&.name
        rarity = badge.rarity.name
        recharge_cost = calculate_recharge_cost(rarity)
        bft_per_minute = calculate_bft_per_minute(badge)
        max_energy = calculate_max_energy(badge)
        bft_value_per_max_charge = calculate_bft_value_per_max_charge(badge)

        {
          "1. rarity": rarity,
          "2. item": Constants::BADGE_NAMES[rarity] || "Unknown",
          "3. supply": badge.supply || 0,
          "4. floor_price": format_currency(badge.floorPrice),
          "5. max_energy": max_energy,
          "6. time_to_charge": calculate_recharge_time(badge),
          "7. in_game_time": calculate_in_game_time(badge),
          "8. recharge_cost": format_currency(recharge_cost&.[](:total_usd)),
          "9. bft_per_minute": bft_per_minute,
          "10. bft_per_max_charge": calculate_bft_per_max_charge(badge),
          "11. bft_value_per_max_charge": format_currency(bft_value_per_max_charge),
          "12. roi": calculate_roi(badge, recharge_cost&.[](:total_usd), bft_value_per_max_charge)
        }
      end.compact
    end

    def calculate_badges_details(badges)
      badges.map do |badge|
        rarity = badge.rarity.name
        recharge_cost = calculate_recharge_cost(rarity)
        bft_value_per_max_charge = calculate_bft_value_per_max_charge(badge)

        {
          "1. rarity": rarity,
          "2. badge_price": format_currency(badge.floorPrice),
          "3. full_recharge_price": format_currency(recharge_cost&.[](:total_usd)),
          "4. total_cost": format_currency(badge.floorPrice.to_f + (recharge_cost&.[](:total_usd) || 0)),
          "5. in_game_minutes": calculate_in_game_minutes(badge),
          "6. bft_per_max_charge": calculate_bft_per_max_charge(badge),
          "7. bft_value": format_currency(bft_value_per_max_charge),
          "8. roi": calculate_roi(badge, recharge_cost&.[](:total_usd), bft_value_per_max_charge)
        }
      end
    end

    def calculate_in_game_time(badge)
      minutes = calculate_in_game_minutes(badge)
      "#{minutes / 60}h"
    end

    def calculate_in_game_minutes(badge)
      return 0 unless badge&.rarity&.name && Constants::RARITY_ORDER.include?(badge.rarity.name)

      base_time = case badge.rarity.name
      when "Common" then 60
      when "Uncommon" then 120
      when "Rare" then 180
      when "Epic" then 240
      when "Legendary" then 300
      when "Mythic" then 360
      when "Exalted" then 420
      when "Exotic" then 480
      when "Transcendent" then 540
      when "Unique" then 600
      else 0
      end

      base_time
    end

    def calculate_bft_per_max_charge(badge)
      bft_per_minute = calculate_bft_per_minute(badge)
      max_energy = calculate_max_energy(badge)
      return nil if bft_per_minute.nil? || max_energy.nil?
      bft_per_minute * max_energy * 60
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
        total_usd: (flex_cost * FLEX_PRICE + sm_cost * BFT_PRICE).round(2)
      }
    end

    def calculate_bft_per_minute(badge)
      return nil unless badge&.item_farming&.efficiency
      case badge.rarity.name
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
      else nil
      end
    end

    def calculate_max_energy(badge)
      return nil unless badge&.rarity&.name
      case badge.rarity.name
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
      else nil
      end
    end

    def calculate_recharge_time(badge)
      return nil unless badge&.rarity&.name && Constants::RARITY_ORDER.include?(badge.rarity.name)
      case badge.rarity.name
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
      else "8h00"
      end
    end

    def calculate_roi(badge, recharge_cost, bft_value_per_max_charge)
      return nil if badge.nil? || recharge_cost.nil? || bft_value_per_max_charge.nil? || bft_value_per_max_charge.zero?

      total_cost = badge.floorPrice.to_f + recharge_cost.to_f
      return nil if total_cost.zero?

      # ROI = Temps de retour sur investissement en nombre de recharges
      (total_cost / bft_value_per_max_charge).round(2)
    end

    def calculate_bft_value_per_max_charge(badge)
      bft_per_max = calculate_bft_per_max_charge(badge)
      return nil if bft_per_max.nil?
      (bft_per_max * BFT_PRICE).round(2)
    end

    def format_currency(amount)
      return nil if amount.nil?
      return nil if amount == "???"
      "$#{'%.2f' % amount}"
    end
  end
end
