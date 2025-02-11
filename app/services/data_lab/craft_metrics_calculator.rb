module DataLab
  class CraftMetricsCalculator
    RARITY_ORDER = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exalted", "Exotic", "Transcendent", "Unique"]

    def initialize(user)
      @user = user
      @badges = load_badges
    end

    def calculate
      @badges.map do |badge|
        {
          "1. rarity": badge.rarity.name,
          "2. supply": badge.supply,
          "3. nb_previous_rarity_item": badge.item_crafting&.nb_lower_badge_to_craft || 0,
          "4. bft": calculate_bft(badge),
          "5. bft_cost": format_currency(calculate_bft_cost(badge)),
          "6. sp_marks_reward": calculate_sp_marks_reward(badge),
          "7. sp_marks_value": format_currency(calculate_sp_marks_value(badge))
        }
      end
    end

    private

    def load_badges
      Item.includes(:type, :rarity, :item_crafting, :item_farming, :item_recharge)
          .joins(:rarity)
          .where(types: { name: 'Badge' })
          .sort_by { |badge| RARITY_ORDER.index(badge.rarity.name) }
    end

    def calculate_bft(badge)
      return 0 unless badge.item_farming

      # Calcul basé sur l'efficacité et le ratio du badge
      base_bft = badge.item_farming.efficiency * 100
      (base_bft * badge.item_farming.ratio).round(0)
    end

    def calculate_bft_cost(badge)
      return 0 unless badge.item_recharge

      # Le coût en $BFT est basé sur les coûts de recharge
      flex_cost = badge.item_recharge.flex_charge * 0.0077 # Prix du FLEX
      sp_marks_cost = badge.item_recharge.sponsor_mark_charge * 0.01 # Prix des Sponsor Marks
      (flex_cost + sp_marks_cost).round(2)
    end

    def calculate_sp_marks_reward(badge)
      return 0 unless badge.item_recharge

      # Les Sponsor Marks sont basés sur la recharge
      badge.item_recharge.sponsor_mark_charge
    end

    def calculate_sp_marks_value(badge)
      sp_marks = calculate_sp_marks_reward(badge)
      return nil if sp_marks.zero?
      (sp_marks * 0.01).round(2) # Valeur en dollars (1 SP Mark = $0.01)
    end

    def format_currency(amount)
      return nil if amount.nil?
      "$#{amount}"
    end
  end
end
