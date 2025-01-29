class MetricsCalculator
  def initialize(item, user = nil)
    @item = item
    @user = user
  end

  def calculate_badge_metrics
    return unless @item.type.name == 'Badge'
    {
      # Métriques de base
      rarity: @item.rarity.name,
      floor_price: @item.floorPrice,
      efficiency: @item.efficiency,
      supply: @item.supply,
      ratio: @item.item_farming&.ratio || 1.0,

      # Métriques de recharge
      max_energy: @item.item_recharge&.max_energy_recharge || 1,
      time_to_charge: @item.item_recharge&.time_to_charge || "8h00",
      recharge_cost: @item.item_recharge&.unit_charge_cost || 0,

      # Métriques calculées
      sbft_per_minute: calculate_sbft_per_minute,
      sbft_per_charge: calculate_sbft_per_charge,
      sbft_value_per_charge: calculate_sbft_value_per_charge

      # Métriques ROI (à implémenter plus tard)
      # matches_to_roi: calculate_matches_to_roi,
      # daily_matches_possible: calculate_daily_matches_possible,
      # estimated_days_to_roi: calculate_estimated_days_to_roi
    }
  end

  def calculate_contract_metrics
    return unless @item.type.name == 'Showrunner'
    {
      # Métriques de base
      rarity: @item.rarity.name,
      name: @item.name,
      supply: @item.supply,
      floor_price: @item.floorPrice,

      # Requirements
      required_matches: @item.item_farming&.in_game_time || 10,
      required_win_rate: @item.efficiency,
      reward_amount: @item.floorPrice

      # Progress (à implémenter plus tard)
      # progress: calculate_contract_progress if @user
    }
  end

  private

  def calculate_sbft_per_minute
    (@item.efficiency * (@item.item_farming&.ratio || 1.0)).round(2)
  end

  def calculate_sbft_per_charge
    sbft_per_minute * (@item.item_recharge&.max_energy_recharge || 1)
  end

  def calculate_sbft_value_per_charge
    (sbft_per_charge * @item.floorPrice).round(2)
  end

=begin
  def calculate_matches_to_roi
    return 0 unless @item.item_recharge && @item.item_crafting

    total_badge_cost = @item.item_crafting.flex_craft
    recharge_cost = @item.item_recharge.unit_charge_cost
    bft_per_recharge = @item.efficiency * @item.item_recharge.max_energy_recharge

    total_cost = total_badge_cost + recharge_cost
    recharges_needed = ((total_cost / bft_per_recharge) - 1)
    total_recharge_cost = recharges_needed * recharge_cost

    total_investment = total_cost + total_recharge_cost
    (total_investment / bft_per_recharge).ceil
  end

  def calculate_daily_matches_possible
    average_match_duration = 10 # minutes
    (24 * 60) / average_match_duration
  end

  def calculate_estimated_days_to_roi
    (calculate_matches_to_roi.to_f / calculate_daily_matches_possible).ceil
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
=end
end
