require 'csv'

# Generate partners
partner_attributes = [
  { name: 'HG Brasil' , slug: 'hg_brasil' }
]

partner_attributes.each do |partner_attributes|
  if !Partner.exists?(slug: partner_attributes[:slug])
    Partner.create!(partner_attributes)
    puts "#{partner_attributes[:slug]} partner created!"
  end
end

# Generate partner resources
partner_resources_attributes = [
  { 
    slug: 'hg_brasil_stock_price',
    name: 'HG Brasil - Stock Price',
    description: 'API that retrieves brazilian asset prices with a delay between 15 minutes up to 1 hour. The endpoint example is: https://api.hgbrasil.com/finance/stock_price?key=282f20db&symbol=embr3',
    url: 'https://console.hgbrasil.com/documentation/finance',
    partner: Partner.find_by(slug: 'hg_brasil')
  },
  {
    slug: 'hg_brasil_quotation',
    name: 'HG Brasil - Quotation',
    description: 'API that retrieves the quotation of currencies and cryptocurrencies. The endpoint example is: https://api.hgbrasil.com/finance/quotations',
    url: 'https://console.hgbrasil.com/documentation/finance',
    partner: Partner.find_by(slug: 'hg_brasil')
  }
]

partner_resources_attributes.each do |partner_resource_attribute|
  if !PartnerResource.exists?(slug: partner_resource_attribute[:slug])
    PartnerResource.create!(partner_resource_attribute)
    puts "#{partner_resource_attribute[:slug]} partner resource created!"
  end
end

# Generate currencies
currencies_csv = File.read(Rails.root.join('db', 'csv', 'currencies.csv'))
parsed_currencies_csv = CSV.parse(currencies_csv, headers: true, encoding: 'utf-8')

parsed_currencies_csv.each do |row|
  name = row['currency name']
  code = row['currency code']

  if !Currency.exists?(code: code, name: name)
    Currency.create!(name: name, code: code)
    puts "#{name}(#{code}) currency created!"
  end
end

brl_currency = Currency.find_by(code: 'BRL')

Currency.all.each do |currency|
  next if currency.code == 'BRL'

  if !CurrencyParity.exists?(currency_from: currency, currency_to: brl_currency)
    CurrencyParity.create!(currency_from: currency, currency_to: brl_currency)
    puts "#{currency.code} to BRL currency_parity created!"
  end
end
