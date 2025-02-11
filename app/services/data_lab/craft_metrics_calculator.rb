module DataLab
  class CraftMetricsCalculator
    include Constants::Utils
    include Constants::Calculator

    def initialize(user)
      @user = user
      @badges = load_badges
    end

    def calculate
      @badges.map do |badge|
        rarity = badge.rarity.name
        {
          "1. rarity": rarity,
          "2. supply": Constants::BADGE_SUPPLY[rarity],
          "3. nb_previous_rarity_item": badge.item_crafting&.nb_lower_badge_to_craft || 0,
          "4. bft": calculate_bft(badge),
          "5. bft_cost": format_currency(calculate_bft_cost(badge)),
          "6. sp_marks_reward": calculate_sp_marks_reward(rarity),
          "7. sp_marks_value": format_currency(calculate_sp_marks_value(rarity))
        }
      end
    end

    private

    def load_badges
      Item.includes(:type, :rarity, :item_crafting, :item_farming, :item_recharge)
          .joins(:rarity)
          .where(types: { name: 'Badge' })
          .sort_by { |badge| Constants::RARITY_ORDER.index(badge.rarity.name) }
    end

    def calculate_bft(badge)
      return 0 unless badge.item_farming

      base_bft = Constants::BFT_PER_MINUTE[badge.rarity.name] || 0
      ratio = Constants::BADGE_RATIOS[badge.rarity.name] || 1.0
      (base_bft * ratio * 60).round(0)  # BFT par heure
    end

    def calculate_bft_cost(badge)
      rarity = badge.rarity.name
      recharge_cost = Constants::Calculator.calculate_recharge_cost(rarity)
      recharge_cost[:total_usd]
    end

    def calculate_sp_marks_reward(rarity)
      Constants::SPONSOR_MARKS[rarity] || 0
    end

    def calculate_sp_marks_value(rarity)
      sp_marks = calculate_sp_marks_reward(rarity)
      return nil if sp_marks.zero?
      (sp_marks * Constants::SM_TO_USD).round(2)
    end

    def format_currency(amount)
      return nil if amount.nil?
      "$#{amount}"
    end
  end
end
