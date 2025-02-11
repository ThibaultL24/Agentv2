module DataLab
  class SlotsMetricsCalculator
    include Constants::Utils
    include Constants::Calculator

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
            amount: Constants::SLOT_COSTS[slot.id],
            currency: "FLEX",
            price_usd: format_currency(Constants::SLOT_COSTS[slot.id] * Constants::FLEX_TO_USD)
          },
          bonus_sbft_per_slot: Constants::SLOT_BONUS_PERCENTAGES[slot.id] || 0,
          normal_part_sbft_badge: calculate_normal_part_sbft(@badge_rarity),
          bonus_part_sbft_badge: calculate_bonus_part_sbft(slot.id, @badge_rarity)
        }
      end
    end

    def calculate_unlocked_slots(user_slots)
      return empty_totals if user_slots.empty?

      unlocked_slot_ids = user_slots.pluck(:slot_id)
      total_flex = unlocked_slot_ids.sum { |id| Constants::SLOT_COSTS[id] || 0 }
      total_cost = (total_flex * Constants::FLEX_TO_USD).round(2)

      {
        total_flex: total_flex,
        total_cost: format_currency(total_cost),
        total_bonus_sbft: Constants::SLOT_MULTIPLIERS[user_slots.count] || 0,
        nb_tokens_roi: calculate_tokens_roi(total_cost),
        charges_roi: calculate_charges_roi(user_slots.count)
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

    def calculate_normal_part_sbft(rarity)
      Constants::BFT_PER_MINUTE[rarity] || 15
    end

    def calculate_bonus_part_sbft(slot_id, rarity)
      base_bonus = Constants::SLOT_BONUS_VALUES[slot_id] || 0
      ratio = Constants::BADGE_RATIOS[rarity] || 1.0
      (base_bonus * ratio).round(2)
    end

    def calculate_tokens_roi(total_cost)
      (total_cost * 100).to_i
    end

    def calculate_charges_roi(nb_slots)
      {
        multiplier_1: Constants::CHARGES_ROI[nb_slots]&.dig(:multiplier_1) || 0,
        multiplier_2: Constants::CHARGES_ROI[nb_slots]&.dig(:multiplier_2) || 0,
        multiplier_3: Constants::CHARGES_ROI[nb_slots]&.dig(:multiplier_3) || 0
      }
    end

    def format_currency(amount)
      "$#{'%.2f' % amount}"
    end
  end
end
