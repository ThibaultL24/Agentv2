class MetricsCalculator
  # Métriques de base par rareté
  BASE_METRICS = {
    'Common' => {
      efficiency: 1.00,
      ratio: 1.00,
      charges: 1,
      matches_per_charge: 6,
      matches_per_day: 6,
      bft_per_minute: 5,
      bft_per_charge: 300,
      bft_per_day: 300,
      craft_time: 48,
      flex_craft: 1300,
      sponsor_marks: 0,
      recharge_time: 48  # heures
    },
    'Uncommon' => {
      efficiency: 2.05,
      ratio: 2.05,
      charges: 2,
      matches_per_charge: 6,
      matches_per_day: 12,
      bft_per_minute: 8,
      bft_per_charge: 960,
      bft_per_day: 1230,
      craft_time: 72,
      flex_craft: 290,
      sponsor_marks: 2430,
      recharge_time: 48
    },
    'Rare' => {
      efficiency: 4.20,
      ratio: 2.15,
      charges: 3,
      matches_per_charge: 6,
      matches_per_day: 18,
      bft_per_minute: 10,
      bft_per_charge: 1800,
      bft_per_day: 3780,
      craft_time: 96,
      flex_craft: 1400,
      sponsor_marks: 4053,
      recharge_time: 48
    },
    'Epic' => {
      efficiency: 12.92,
      ratio: 8.72,
      charges: 4,
      matches_per_charge: 6,
      matches_per_day: 24,
      bft_per_minute: 15,
      bft_per_charge: 3600,
      bft_per_day: 15504,
      craft_time: 120,
      flex_craft: 6300,
      sponsor_marks: 10142,
      recharge_time: 48
    },
    'Legendary' => {
      efficiency: 39.74,
      ratio: 26.82,
      charges: 5,
      matches_per_charge: 6,
      matches_per_day: 30,
      bft_per_minute: 20,
      bft_per_charge: 6000,
      bft_per_day: 59610,
      craft_time: 144,
      flex_craft: 25900,
      sponsor_marks: 16919,
      recharge_time: 48
    },
    'Mythic' => {
      efficiency: 122.19,
      ratio: 82.45,
      charges: 6,
      matches_per_charge: 6,
      matches_per_day: 36,
      bft_per_minute: 30,
      bft_per_charge: 10800,
      bft_per_day: 219942,
      craft_time: 168,
      flex_craft: 92700,
      sponsor_marks: 28222,
      recharge_time: 48
    }
  }.freeze

  # Coûts de recharge par rareté (en FLEX)
  RECHARGE_COSTS = {
    'Common' => {
      single: 500,
      full: 500,
      sponsor_marks_required: 150
    },
    'Uncommon' => {
      single: 1400,
      full: 2800,
      sponsor_marks_required: 350
    },
    'Rare' => {
      single: 3300,
      full: 9900,
      sponsor_marks_required: 876
    },
    'Epic' => {
      single: 1600,
      full: 6400,
      sponsor_marks_required: 1948
    },
    'Legendary' => {
      single: 12000,
      full: 60000,
      sponsor_marks_required: 4065
    },
    'Mythic' => {
      single: 23500,
      full: 141000,
      sponsor_marks_required: 8400
    }
  }.freeze

  FLEX_TO_USD = 0.0077  # Taux de conversion FLEX -> USD
  BFT_TO_USD = 0.01     # Taux de conversion BFT -> USD
  SM_TO_USD = 0.01      # Taux de conversion Sponsor Mark -> USD

  def initialize(item, user = nil)
    @item = item
    @user = user
    @metrics = BASE_METRICS[@item.rarity.name]
  end

  def calculate_badge_metrics
    return unless @item.type.name == 'Badge'
    {
      # Métriques de base
      rarity: @item.rarity.name,
      efficiency: @metrics[:efficiency],
      ratio: @metrics[:ratio],
      max_charges: @metrics[:charges],
      matches_per_charge: @metrics[:matches_per_charge],
      matches_per_day: @metrics[:matches_per_day],

      # Métriques de farming
      bft_per_minute: @metrics[:bft_per_minute],
      bft_per_charge: @metrics[:bft_per_charge],
      bft_per_day: @metrics[:bft_per_day],

      # Métriques de craft
      craft_time: @metrics[:craft_time],
      flex_craft_cost: @metrics[:flex_craft],
      sponsor_marks_cost: @metrics[:sponsor_marks],
      total_craft_cost_usd: calculate_total_craft_cost,

      # Métriques de recharge
      recharge_time: @metrics[:recharge_time],
      recharge_costs: get_recharge_cost,

      # Métriques économiques
      estimated_profit_per_day: calculate_daily_profit,
      roi_days: calculate_roi_days
    }
  end

  def calculate_contract_metrics
    return unless @item.type.name == 'Contract'
    {
      # Métriques de base
      rarity: @item.rarity.name,
      name: @item.name,
      supply: @item.supply,
      floor_price: @item.floorPrice,
      efficiency: @item.efficiency,
      farming_time: @item.item_farming&.in_game_time || 600,

      # Métriques de craft
      craft_time: @metrics[:craft_time],
      nb_badges_required: @item.item_crafting&.nb_lower_badge_to_craft,
      flex_craft_cost: @item.item_crafting&.flex_craft,
      sponsor_marks_cost: @item.item_crafting&.sponsor_mark_craft,
      total_craft_cost_usd: calculate_total_craft_cost,

      # Métriques de progression
      required_matches: @item.item_farming&.in_game_time || 10,
      required_win_rate: @item.efficiency,
      reward_amount: @item.floorPrice,
      progress: calculate_contract_progress if @user
    }
  end

  private

  def get_recharge_cost
    costs = RECHARGE_COSTS[@item.rarity.name]
    {
      single_charge: {
        flex: costs[:single],
        sponsor_marks: costs[:sponsor_marks_required],
        usd: calculate_recharge_usd_cost(costs[:single], costs[:sponsor_marks_required])
      },
      full_charges: {
        flex: costs[:full],
        sponsor_marks: costs[:sponsor_marks_required] * @metrics[:charges],
        usd: calculate_recharge_usd_cost(costs[:full], costs[:sponsor_marks_required] * @metrics[:charges])
      }
    }
  end

  def calculate_recharge_usd_cost(flex_amount, sm_amount)
    flex_cost = flex_amount * FLEX_TO_USD
    sm_cost = sm_amount * SM_TO_USD
    (flex_cost + sm_cost).round(2)
  end

  def calculate_daily_profit
    daily_income = @metrics[:bft_per_day] * BFT_TO_USD
    recharge_cost = get_recharge_cost[:single_charge][:usd] * (24 / @metrics[:recharge_time])
    (daily_income - recharge_cost).round(2)
  end

  def calculate_roi_days
    return 0 unless @item.floorPrice && @item.floorPrice > 0

    daily_profit = calculate_daily_profit
    return Float::INFINITY if daily_profit <= 0

    (@item.floorPrice / daily_profit).ceil
  end

  def calculate_total_craft_cost
    flex_cost = @metrics[:flex_craft] * FLEX_TO_USD
    sponsor_cost = @metrics[:sponsor_marks] * SM_TO_USD
    (flex_cost + sponsor_cost).round(2)
  end

  def calculate_contract_progress
    return unless @user
    matches = @user.matches
                  .where('created_at >= ?', 24.hours.ago)
                  .where(game_id: @item.game_id)

    total_matches = matches.count
    won_matches = matches.where(result: 'win').count
    win_rate = total_matches > 0 ? (won_matches.to_f / total_matches * 100).round(2) : 0

    {
      matches_played: total_matches,
      matches_required: @item.item_farming&.in_game_time || 10,
      current_win_rate: win_rate,
      required_win_rate: @item.efficiency,
      completion_percentage: calculate_completion_percentage(total_matches, win_rate)
    }
  end

  def calculate_completion_percentage(total_matches, win_rate)
    return 0 if total_matches == 0

    matches_percentage = [total_matches.to_f / (@item.item_farming&.in_game_time || 10) * 100, 100].min
    win_rate_percentage = [win_rate / @item.efficiency * 100, 100].min

    [(matches_percentage + win_rate_percentage) / 2, 100].min
  end
end
