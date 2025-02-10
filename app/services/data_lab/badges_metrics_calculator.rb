module DataLab
  class BadgesMetricsCalculator
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
      badges = Item.includes(:type, :rarity, :item_farming, :item_recharge, :item_crafting, :nfts)
                  .joins(:rarity)
                  .where(types: { name: 'Badge' })
                  .sort_by { |badge| RARITY_ORDER.index(badge.rarity.name) }

      {
        badges_cost: calculate_badges_metrics(badges),
        market_metrics: calculate_badge_details(badges)
      }
    end

    private

    def calculate_badges_metrics(badges)
      badges.map do |badge|
        metrics = BADGE_METRICS[badge.rarity.name]
        {
          rarity: badge.rarity.name,
          name: metrics[:name],
          supply: metrics[:supply],
          floor_price: metrics[:floor_price],
          efficiency: metrics[:efficiency],
          ratio: metrics[:ratio],
          max_energy: metrics[:max_energy],
          time_to_charge: convert_time_to_minutes(metrics[:time_to_charge]),
          in_game_time: convert_time_to_minutes(metrics[:in_game_time]),
          max_charge_cost: metrics[:max_charge_cost],
          cost_per_hour: metrics[:cost_per_hour],
          sbft_per_minute: metrics[:sbft_per_minute],
          sbft_per_max_charge: metrics[:sbft_per_max_charge],
          sbft_value: metrics[:sbft_value],
          roi_multiplier: metrics[:roi]
        }
      end
    end

    def calculate_badge_details(badges)
      badges.map do |badge|
        metrics = BADGE_METRICS[badge.rarity.name]
        {
          rarity: badge.rarity.name,
          market_data: {
            supply: {
              total: metrics[:supply],
              minted: badge.nfts.count,
              available: metrics[:supply] - badge.nfts.count
            },
            price: {
              floor: format_currency(metrics[:floor_price]),
              last_sold: format_currency(badge.nfts.order(created_at: :desc).first&.purchasePrice)
            }
          },
          recharge: {
            max_energy: metrics[:max_energy],
            time_to_charge: metrics[:time_to_charge],
            costs: {
              full: format_currency(metrics[:max_charge_cost]),
              single_energy: format_currency(calculate_one_energy_cost(badge)),
              total: format_currency(calculate_total_cost(badge))
            }
          },
          farming: {
            efficiency: metrics[:efficiency],
            ratio: metrics[:ratio],
            in_game_minutes: metrics[:in_game_time].to_i * 60,
            sbft: {
              per_minute: metrics[:sbft_per_minute],
              per_max_charge: metrics[:sbft_per_max_charge],
              value: format_currency(metrics[:sbft_value])
            }
          },
          roi: {
            charges_needed: calculate_nb_charges_roi(badge),
            multiplier: metrics[:roi]
          }
        }
      end
    end

    def calculate_one_energy_cost(badge)
      metrics = BADGE_METRICS[badge.rarity.name]
      return "???" if metrics[:max_charge_cost] == "???" || metrics[:max_energy] == "???"

      # Coût d'une unité d'énergie = coût total / nombre d'énergies max
      (metrics[:max_charge_cost] / metrics[:max_energy]).round(2)
    end

    def calculate_total_cost(badge)
      metrics = BADGE_METRICS[badge.rarity.name]
      return "???" if metrics[:floor_price] == "???" || metrics[:max_charge_cost] == "???"

      # Prix d'achat du badge + coût de recharge complet
      badge_price = metrics[:floor_price]
      recharge_cost = metrics[:max_charge_cost]
      (badge_price + recharge_cost).round(2)
    end

    def calculate_nb_charges_roi(badge)
      metrics = BADGE_METRICS[badge.rarity.name]
      return "???" if metrics[:floor_price] == "???" || metrics[:max_charge_cost] == "???" ||
                    metrics[:sbft_value] == "???" || metrics[:sbft_per_max_charge] == "???"

      total_investment = metrics[:floor_price]  # Coût initial du badge
      charge_cost = metrics[:max_charge_cost]   # Coût par recharge
      revenue_per_charge = metrics[:sbft_value] # Revenu par recharge complète

      return "???" if revenue_per_charge == 0

      # Nombre de recharges nécessaires pour rentabiliser l'investissement
      charges_needed = total_investment / (revenue_per_charge - charge_cost)
      charges_needed.ceil(2)
    end

    def calculate_hourly_cost(badge)
      metrics = BADGE_METRICS[badge.rarity.name]
      return "???" if metrics[:max_charge_cost] == "???" || metrics[:time_to_charge] == "???"

      time_in_hours = convert_time_to_minutes(metrics[:time_to_charge]) / 60.0
      (metrics[:max_charge_cost] / time_in_hours).round(2)
    end

    def calculate_farming_efficiency(badge)
      metrics = BADGE_METRICS[badge.rarity.name]
      return "???" if metrics[:sbft_per_minute] == "???" || metrics[:max_energy] == "???"

      # Efficacité = SBFT par minute / énergie maximale
      (metrics[:sbft_per_minute].to_f / metrics[:max_energy]).round(3)
    end

    def calculate_roi_multiplier(badge)
      metrics = BADGE_METRICS[badge.rarity.name]
      return "???" if metrics[:floor_price] == "???" || metrics[:sbft_value] == "???"

      # ROI = (Revenu - Coût) / Coût
      total_cost = calculate_total_cost(badge)
      return "???" if total_cost == "???"

      revenue = metrics[:sbft_value]
      ((revenue - total_cost) / total_cost).round(2)
    end

    def convert_time_to_minutes(time_str)
      return "???" if time_str == "???"
      hours, minutes = time_str.match(/(\d+)h(\d+)?/).captures
      hours.to_i * 60 + (minutes || "0").to_i
    end

    def format_currency(amount)
      return "???" if amount.nil? || amount == "???"
      amount
    end
  end
end
