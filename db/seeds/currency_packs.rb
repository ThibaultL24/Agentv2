puts "- Création des currency packs"

# Définition des packs pour chaque currency
Currency.find_each do |currency|
  currency_packs = if currency.name == "Gold"
    [
      { currencyNumber: 100, price: 0.99, unitPrice: 0.0099 },
      { currencyNumber: 500, price: 4.49, unitPrice: 0.00898 },
      { currencyNumber: 1000, price: 8.49, unitPrice: 0.00849 }
    ]
  else # Gems
    [
      { currencyNumber: 10, price: 9.99, unitPrice: 0.999 },
      { currencyNumber: 50, price: 44.99, unitPrice: 0.8998 },
      { currencyNumber: 100, price: 84.99, unitPrice: 0.8499 }
    ]
  end

  puts "  - Création des packs pour #{currency.name}"

  currency_packs.each do |pack_data|
    CurrencyPack.find_or_create_by!(
      currency: currency,
      currencyNumber: pack_data[:currencyNumber]
    ) do |pack|
      pack.price = pack_data[:price]
      pack.unitPrice = pack_data[:unitPrice]
    end
  end
end

puts "✓ Currency packs créés avec succès"
