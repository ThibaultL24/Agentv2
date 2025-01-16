class Badge < ApplicationRecord
  # Ajout des colonnes nécessaires
  # price, recharge_cost, bft_per_recharge, recharge_price

  def calculate_roi_matches
    total_cost = price + recharge_cost
    total_slot_cost = user.calculate_total_slot_cost
    slots = user.unlocked_slots.count + 1

    recharges_needed = ((total_cost / bft_per_recharge) - 1)
    recharge_total_cost = recharges_needed * recharge_price

    total_investment = (
      total_slot_cost +
      (total_cost * slots) +
      (recharges_needed * slots * recharge_price)
    )

    matches_needed = total_investment / (bft_per_recharge * slots)
    matches_needed.ceil
  end
end
