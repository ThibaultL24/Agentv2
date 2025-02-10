module DataLab
  class SlotsMetricsCalculator
    def initialize(user, badge_rarity = "Common")
      @user = user
      @badge_rarity = badge_rarity
    end

    def calculate
      slots = Slot.includes(:currency, :game)
      slots_costs = calculate_slots_cost(slots)
      {
        slots_cost: slots_costs,
        unlocked_slots: calculate_unlocked_slots(@user.user_slots).merge(
          total_cost: format_currency(slots.sum(:unlockPrice))
        )
      }
    end

    private

    def calculate_slots_cost(slots)
      slots.map do |slot|
        {
          slot: slot.id,
          cost: {
            amount: slot.unlockCurrencyNumber,
            currency: slot.currency.name,
            price_usd: format_currency(slot.unlockPrice)
          },
          bonus_sbft_per_slot: calculate_bonus_sbft_percentage(slot),
          normal_part_sbft_badge: calculate_normal_part_sbft(@badge_rarity),
          bonus_part_sbft_badge: calculate_bonus_part_sbft(slot, @badge_rarity)
        }
      end
    end

    def calculate_unlocked_slots(user_slots)
      return empty_totals if user_slots.empty?

      # Log initial user slots information
      Rails.logger.info "==== Calculating Unlocked Slots ===="
      Rails.logger.info "User slots count: #{user_slots.count}"
      Rails.logger.info "User slots details: #{user_slots.inspect}"

      unlocked_slot_ids = user_slots.pluck(:slot_id)
      Rails.logger.info "Unlocked slot IDs: #{unlocked_slot_ids.inspect}"

      # Récupérer tous les slots
      all_slots = Slot.all
      Rails.logger.info "All available slots: #{all_slots.map { |s| { id: s.id, flex: s.unlockCurrencyNumber, price: s.unlockPrice } }.inspect}"

      # Récupérer les slots débloqués
      slots = Slot.where(id: unlocked_slot_ids)
      Rails.logger.info "Found unlocked slots: #{slots.map { |s| { id: s.id, flex: s.unlockCurrencyNumber, price: s.unlockPrice } }.inspect}"

      # Calculer les totaux avec plus de détails
      total_flex = slots.sum(:unlockCurrencyNumber)
      total_cost = slots.sum(:unlockPrice)
      Rails.logger.info "Individual slot costs: #{slots.map { |s| [s.id, s.unlockPrice] }.inspect}"
      Rails.logger.info "Calculated totals: flex=#{total_flex}, raw_cost=#{total_cost}, formatted_cost=#{format_currency(total_cost)}"
      Rails.logger.info "==== End Calculation ===="

      {
        total_flex: total_flex,
        total_cost: format_currency(total_cost),
        total_bonus_sbft: calculate_total_bonus_percentage(user_slots),
        nb_tokens_roi: (total_cost * 100).to_i,
        charges_roi: {
          multiplier_1: calculate_charges_roi(user_slots, 1.0),
          multiplier_2: calculate_charges_roi(user_slots, 2.0),
          multiplier_3: calculate_charges_roi(user_slots, 3.0)
        }
      }
    end

    def empty_totals
      {
        total_flex: 0,
        total_cost: format_currency(0),
        total_bonus_sbft: 0,
        nb_tokens_roi: 0,
        charges_roi: {
          multiplier_1: 0,
          multiplier_2: 0,
          multiplier_3: 0
        }
      }
    end

    def calculate_bonus_sbft_percentage(slot)
      case slot.id
      when 1 then 0
      when 2 then 0.5
      when 3 then 1.5
      when 4 then 3.0
      when 5 then 5.0
      end
    end

    def calculate_normal_part_sbft(rarity)
      # Récupérer les métriques du badge selon sa rareté
      badge_metrics = BadgesMetricsCalculator::BADGE_METRICS[rarity]
      return 15 if badge_metrics.nil? # Valeur par défaut si la rareté n'est pas trouvée

      # Utiliser directement sbft_per_minute du badge
      badge_metrics[:sbft_per_minute]
    end

    def calculate_bonus_part_sbft(slot, rarity)
      base_bonus = case slot.id
        when 1 then 0
        when 2 then 1
        when 3 then 2
        when 4 then 4
        when 5 then 6
      end

      # Appliquer le multiplicateur basé sur la rareté
      badge_metrics = BadgesMetricsCalculator::BADGE_METRICS[rarity]
      return base_bonus if badge_metrics.nil?

      # Multiplier le bonus de base par le ratio du badge
      (base_bonus * badge_metrics[:ratio]).round(2)
    end

    def calculate_total_bonus_percentage(user_slots)
      case user_slots.count
      when 1 then 1.0
      when 2 then 4.5
      when 3 then 12.0
      when 4 then 25.0
      when 5 then 40.0
      else 0
      end
    end

    def calculate_charges_roi(user_slots, multiplier)
      case [user_slots.count, multiplier]
      when [1, 1.0] then 5
      when [1, 2.0] then 3
      when [1, 3.0] then 2
      when [2, 1.0] then 10
      when [2, 2.0] then 5
      when [2, 3.0] then 4
      when [3, 1.0] then 19
      when [3, 2.0] then 10
      when [3, 3.0] then 7
      when [4, 1.0] then 29
      when [4, 2.0] then 15
      when [4, 3.0] then 10
      when [5, 1.0] then 40
      when [5, 2.0] then 20
      when [5, 3.0] then 13
      else 0
      end
    end

    def format_currency(amount)
      "$#{'%.2f' % amount}"
    end
  end
end
