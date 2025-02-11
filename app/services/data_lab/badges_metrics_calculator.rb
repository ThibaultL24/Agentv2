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
        rarity = badge.rarity.name
        recharge_cost = Constants::Calculator.calculate_recharge_cost(rarity)
        hourly_bft = Constants::Calculator.calculate_hourly_bft(rarity)
        daily_profit = Constants::Calculator.calculate_daily_profit(rarity, 1)

        {
          rarity: rarity,
          item: get_badge_name(rarity),
          supply: Constants::BADGE_SUPPLY[rarity],
          floor_price: format_currency(badge.floorPrice),
          efficiency: Constants::BASE_EFFICIENCY[rarity],
          ratio: Constants::BADGE_RATIOS[rarity],
          max_energy: Constants::MAX_ENERGY[rarity],
          time_to_charge: Constants::RECHARGE_TIMES[rarity],
          in_game_time: calculate_in_game_time(rarity),
          max_charge_cost: format_currency(recharge_cost[:total_usd]),
          cost_per_hour: format_currency(calculate_cost_per_hour(rarity)),
          sbft_per_minute: Constants::BFT_PER_MINUTE[rarity],
          sbft_per_max_charge: calculate_sbft_per_max_charge(rarity),
          sbft_value_per_max_charge: format_currency(calculate_sbft_value_per_max_charge(rarity)),
          roi: calculate_roi(badge, daily_profit)
        }
      end
    end

    def calculate_badges_details(badges)
      badges.map do |badge|
        rarity = badge.rarity.name
        recharge_cost = Constants::Calculator.calculate_recharge_cost(rarity)

        {
          rarity: rarity,
          badge_price: format_currency(badge.floorPrice),
          full_recharge_price: format_currency(recharge_cost[:total_usd]),
          one_energy_recharge_price: format_currency(calculate_one_energy_cost(rarity)),
          total_cost: format_currency(calculate_total_cost(badge, recharge_cost)),
          in_game_minutes: calculate_in_game_minutes(rarity),
          sbft_per_max_recharge: calculate_sbft_per_max_recharge(rarity),
          sbft_value: format_currency(calculate_sbft_value(rarity)),
          nb_charges_roi: calculate_nb_charges_roi(badge, recharge_cost)
        }
      end
    end

    def calculate_cost_per_hour(rarity)
      recharge_cost = Constants::Calculator.calculate_recharge_cost(rarity)
      max_energy = Constants::MAX_ENERGY[rarity]
      return nil if max_energy.nil? || max_energy.zero?
      (recharge_cost[:total_usd] / max_energy).round(2)
    end

    def calculate_sbft_per_max_charge(rarity)
      bft_per_minute = Constants::BFT_PER_MINUTE[rarity]
      max_energy = Constants::MAX_ENERGY[rarity]
      return nil if bft_per_minute.nil? || max_energy.nil?
      bft_per_minute * 60 * max_energy
    end

    def calculate_sbft_value_per_max_charge(rarity)
      sbft = calculate_sbft_per_max_charge(rarity)
      return nil if sbft.nil?
      (sbft * Constants::BFT_TO_USD).round(2)
    end

    def calculate_roi(badge, daily_profit)
      return nil if badge.floorPrice.nil? || daily_profit.nil? || daily_profit[:profit].to_f <= 0
      (badge.floorPrice / daily_profit[:profit]).round(2)
    end

    def calculate_one_energy_cost(rarity)
      recharge_cost = Constants::Calculator.calculate_recharge_cost(rarity)
      max_energy = Constants::MAX_ENERGY[rarity]
      return nil if max_energy.nil? || max_energy.zero?
      (recharge_cost[:total_usd] / max_energy).round(2)
    end

    def calculate_total_cost(badge, recharge_cost)
      return nil if badge.floorPrice.nil? || recharge_cost.nil?
      (badge.floorPrice + recharge_cost[:total_usd]).round(2)
    end

    def calculate_in_game_minutes(rarity)
      max_energy = Constants::MAX_ENERGY[rarity]
      return nil if max_energy.nil?
      max_energy * 60
    end

    def calculate_sbft_per_max_recharge(rarity)
      bft_per_minute = Constants::BFT_PER_MINUTE[rarity]
      max_energy = Constants::MAX_ENERGY[rarity]
      return nil if bft_per_minute.nil? || max_energy.nil?
      (bft_per_minute * max_energy * 8).round(0)
    end

    def calculate_sbft_value(rarity)
      sbft = calculate_sbft_per_max_recharge(rarity)
      return nil if sbft.nil?
      (sbft * Constants::BFT_TO_USD).round(2)
    end

    def calculate_nb_charges_roi(badge, recharge_cost)
      return nil if badge.floorPrice.nil? || recharge_cost.nil? || recharge_cost[:total_usd].zero?

      total_cost = calculate_total_cost(badge, recharge_cost)
      value_bft_max_charge = calculate_sbft_value_per_max_charge(badge.rarity.name)
      recharge_price = recharge_cost[:total_usd]

      return nil if value_bft_max_charge.nil? || value_bft_max_charge.zero?

      (total_cost + (((total_cost / value_bft_max_charge) - 1) * recharge_price)) / value_bft_max_charge
    end

    def get_badge_name(rarity)
      Constants::BADGE_NAMES[rarity] || rarity
    end

    def calculate_in_game_time(rarity)
      max_energy = Constants::MAX_ENERGY[rarity]
      "%02dh00" % max_energy
    end

    def format_currency(amount)
      return nil if amount.nil?
      amount
    end
  end
end
