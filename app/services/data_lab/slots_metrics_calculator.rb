module DataLab
  class SlotsMetricsCalculator
    def initialize(user)
      @user = user
    end

    def calculate
      slots = Slot.includes(:currency, :game)
      {
        slots_cost: calculate_slots_cost(slots),
        unlocked_slots: calculate_unlocked_slots(@user.user_slots)
      }
    end

    private

    def calculate_slots_cost(slots)
      slots.map do |slot|
        {
          slot: slot.id,
          nb_flex: slot.unlockCurrencyNumber,
          flex_cost: format_currency(slot.unlockPrice),
          bonus_sbft_per_slot: calculate_bonus_sbft_percentage(slot),
          normal_part_sbft_badge: 14,
          bonus_part_sbft_badge: calculate_bonus_part_sbft(slot)
        }
      end
    end

    def calculate_unlocked_slots(user_slots)
      {
        total_flex: calculate_total_flex(user_slots),
        total_cost: format_currency(calculate_total_cost(user_slots)),
        total_bonus_sbft: calculate_total_bonus_percentage(user_slots),
        nb_tokens_roi: calculate_tokens_roi(user_slots),
        charges_roi: {
          multiplier_1: calculate_charges_roi(user_slots, 1.0),
          multiplier_2: calculate_charges_roi(user_slots, 2.0),
          multiplier_3: calculate_charges_roi(user_slots, 3.0)
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

    def calculate_bonus_part_sbft(slot)
      case slot.id
      when 1 then 0
      when 2 then 1
      when 3 then 2
      when 4 then 4
      when 5 then 6
      end
    end

    def calculate_total_flex(user_slots)
      case user_slots.count
      when 1 then 7_000
      when 2 then 20_000
      when 3 then 40_000
      when 4 then 66_000
      when 5 then 100_000
      else 0
      end
    end

    def calculate_total_cost(user_slots)
      case user_slots.count
      when 1 then 51.98
      when 2 then 148.52
      when 3 then 297.04
      when 4 then 490.11
      when 5 then 750.00
      else 0
      end
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

    def calculate_tokens_roi(user_slots)
      case user_slots.count
      when 1 then 5_198
      when 2 then 14_852
      when 3 then 29_704
      when 4 then 49_011
      when 5 then 75_000
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
