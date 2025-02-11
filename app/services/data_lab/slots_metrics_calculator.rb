module DataLab
  class SlotsMetricsCalculator
    include Constants::Utils
    include Constants::Calculator

    def initialize(user, badge_rarity = "Common")
      @user = user
      @badge_rarity = badge_rarity || "Common"
    end

    def calculate
      slots = Slot.includes(:currency, :game)
      slots_costs = calculate_slots_cost(slots)

      # Calculer le total des coûts de tous les slots
      total_slots_cost = slots.sum(:unlockPrice)
      total_flex = slots.sum(:unlockCurrencyNumber)
      total_bonus_bft = calculate_total_bonus_bft(@user.user_slots.count)

      {
        slots_cost: slots_costs,
        unlocked_slots: {
          "1. total_flex": total_flex,
          "2. total_cost": format_currency(total_slots_cost),
          "3. total_bonus_bft": total_bonus_bft
        }
      }
    end

    private

    def calculate_slots_cost(slots)
      slots.map do |slot|
        bft_per_minute = calculate_bft_per_minute(@badge_rarity)
        max_energy = calculate_max_energy(@badge_rarity)

        bonus_bft = calculate_bonus_bft_per_slot(slot.id, bft_per_minute)
        total_bft = calculate_total_bft_per_charge(slot.id, bft_per_minute, max_energy)

        {
          "1. slot": slot.id,
          "2. nb_flex": slot.unlockCurrencyNumber,
          "3. flex_cost": format_currency(slot.unlockPrice),
          "4. bonus_bft": bonus_bft,
          "5. total_bft": total_bft
        }
      end
    end

    def calculate_unlocked_slots(user_slots)
      if user_slots.empty?
        return empty_totals
      end

      unlocked_slot_ids = user_slots.pluck(:slot_id)
      slots = Slot.where(id: unlocked_slot_ids)

      total_flex = slots.sum(:unlockCurrencyNumber)
      total_cost = (total_flex * Constants::FLEX_TO_USD).round(2)
      total_bonus_bft = calculate_total_bonus_bft(slots.count)

      {
        "1. total_flex": total_flex,
        "2. total_cost": format_currency(total_cost),
        "3. total_bonus_bft": total_bonus_bft,
        total_flex: Slot.sum(:unlockCurrencyNumber),
        total_cost: format_currency(Slot.sum(:unlockPrice))
      }
    end

    def empty_totals
      {
        "1. total_flex": 0,
        "2. total_cost": format_currency(0),
        "3. total_bonus_bft": 1.2,
        total_flex: Slot.sum(:unlockCurrencyNumber),
        total_cost: format_currency(Slot.sum(:unlockPrice))
      }
    end

    def calculate_bft_per_minute(rarity)
      Constants::Calculator.calculate_bft_per_minute(rarity)
    end

    def calculate_max_energy(rarity)
      Constants::Calculator.calculate_max_energy(rarity)
    end

    def calculate_recharge_cost(rarity)
      Constants::Calculator.calculate_recharge_cost(rarity)
    end

    def calculate_bft_value_per_max_charge(rarity)
      bft_per_minute = calculate_bft_per_minute(rarity)
      max_energy = calculate_max_energy(rarity)
      return nil if bft_per_minute.nil? || max_energy.nil?

      total_bft = bft_per_minute * max_energy * 60
      (total_bft * Constants::BFT_TO_USD).round(2)
    end

    def calculate_bonus_bft_per_slot(slot_id, bft_per_minute)
      return 0 if bft_per_minute.nil?
      # Le bonus augmente de 5% par slot (10%, 15%, 20%, 25%, 30%)
      bonus_percentage = 10 + ((slot_id - 1) * 5)
      (bft_per_minute * (bonus_percentage / 100.0)).round(2)
    end

    def calculate_total_bft_per_charge(slot_id, bft_per_minute, max_energy)
      return 0 if bft_per_minute.nil? || max_energy.nil?
      # BFT total = (BFT de base + bonus) * max_energy * minutes par heure
      base_bft = bft_per_minute
      bonus_bft = calculate_bonus_bft_per_slot(slot_id, bft_per_minute)
      ((base_bft + bonus_bft) * max_energy * 60).round(0)
    end

    def calculate_total_bonus_bft(nb_slots)
      # Le bonus total est de 1 + 0.2 par slot
      1 + (nb_slots * 0.2)
    end

    def calculate_total_slots_roi(slot_total_cost, slots_count, recharge_cost, bft_value_per_max_charge)
      # (Total slot cost + (Total cost*Slots) + ((((Total cost*Slots)/$BFT value 1 recharge)-(1*Slots))*prix1recharge)) / ($BFTvalue1recharge*Slots)
      slots = slots_count + 1
      total_cost = slot_total_cost + recharge_cost

      numerator = slot_total_cost +
                 (total_cost * slots) +
                 ((((total_cost * slots)/bft_value_per_max_charge) - (1 * slots)) * recharge_cost)

      denominator = bft_value_per_max_charge * slots

      (numerator / denominator).round(2)
    end

    def calculate_slot_roi(slot_cost, slot_id, recharge_cost, bft_value_per_max_charge)
      return 0 if slot_cost.nil? || recharge_cost.nil? || bft_value_per_max_charge.nil? || bft_value_per_max_charge.zero?

      slots = slot_id + 1
      total_cost = slot_cost + recharge_cost

      numerator = slot_cost +
                 (total_cost * slots) +
                 ((((total_cost * slots)/bft_value_per_max_charge) - (1 * slots)) * recharge_cost)

      denominator = bft_value_per_max_charge * slots

      (numerator / denominator).round(2)
    end

    def format_currency(amount)
      "$#{'%.2f' % amount}"
    end
  end
end
