puts "\nCréation des cycles de joueurs..."

User.all.each do |user|
  puts "- Création des cycles pour #{user.username}"

  # Cycle quotidien
  PlayerCycle.find_or_create_by!(
    user: user,
    cycleName: "Daily Cycle"
  ) do |cycle|
    cycle.playerCycleType = 1
    cycle.nbBadge = 3
    cycle.minimumBadgeRarity = "Common"
    cycle.startDate = Time.current
    cycle.endDate = 1.day.from_now
    cycle.nbDateRepeat = 1
  end

  # Cycle hebdomadaire
  PlayerCycle.find_or_create_by!(
    user: user,
    cycleName: "Weekly Cycle"
  ) do |cycle|
    cycle.playerCycleType = 2
    cycle.nbBadge = 5
    cycle.minimumBadgeRarity = "Uncommon"
    cycle.startDate = Time.current
    cycle.endDate = 1.week.from_now
    cycle.nbDateRepeat = 7
  end

  # Cycle mensuel
  PlayerCycle.find_or_create_by!(
    user: user,
    cycleName: "Monthly Cycle"
  ) do |cycle|
    cycle.playerCycleType = 3
    cycle.nbBadge = 10
    cycle.minimumBadgeRarity = "Rare"
    cycle.startDate = Time.current
    cycle.endDate = 1.month.from_now
    cycle.nbDateRepeat = 30
  end
end

puts "✓ Cycles de joueurs créés avec succès"
