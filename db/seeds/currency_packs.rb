puts "\nCréation des currency packs..."

# Définition des packs pour chaque currency
Currency.find_each do |currency|
  currency_packs = case currency.name
  when "CASH"
    [
      { currencyNumber: 5_000, price: 4.99, unitPrice: 0.000998 },
      { currencyNumber: 15_000, price: 12.99, unitPrice: 0.000866 },
      { currencyNumber: 50_000, price: 39.99, unitPrice: 0.000799 }
    ]
  when "FLEX"
    [
      { currencyNumber: 500, price: 4.99, unitPrice: 0.00998 },
      { currencyNumber: 1_500, price: 12.99, unitPrice: 0.00866 },
      { currencyNumber: 5_000, price: 39.99, unitPrice: 0.00799 }
    ]
  when "$BFT"
    [
      { currencyNumber: 100, price: 99.99, unitPrice: 0.9999 },
      { currencyNumber: 500, price: 449.99, unitPrice: 0.8999 },
      { currencyNumber: 1_000, price: 849.99, unitPrice: 0.8499 }
    ]
  when "Sponsor Marks"
    [
      { currencyNumber: 1_000, price: 49.99, unitPrice: 0.04999 },
      { currencyNumber: 5_000, price: 224.99, unitPrice: 0.04499 },
      { currencyNumber: 10_000, price: 424.99, unitPrice: 0.04249 }
    ]
  else
    [] # Fame Points ne peuvent pas être achetés directement
  end

  if currency_packs.any?
    puts "- Création des packs pour #{currency.name}"

    currency_packs.each do |pack_data|
      CurrencyPack.find_or_create_by!(
        currency: currency,
        currencyNumber: pack_data[:currencyNumber]
      ) do |pack|
        pack.price = pack_data[:price]
        pack.unitPrice = pack_data[:unitPrice]
        puts "  - Pack de #{pack_data[:currencyNumber]} #{currency.name} à #{pack_data[:price]}$"
      end
    end
  end
end

puts "✓ Currency packs créés avec succès"
