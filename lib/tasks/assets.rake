# frozen_string_literal: true

require 'csv'

namespace :assets do
  desc 'Discover assets in the application base on CSV file'
  task discovery: :environment do
    brazilian_assets_csv = File.read(Rails.root.join('db', 'csv', 'brazilian_assets.csv'))
    parsed_brazilian_assets_csv = CSV.parse(brazilian_assets_csv, headers: true, encoding: 'utf-8')
    delay_in_seconds = 5
    current_delay = 0

    parsed_brazilian_assets_csv.each do |row|
      ticker_symbol = row['ticker_symbol']

      next if ticker_symbol.blank? || Asset.exists?(ticker_symbol:)

      current_delay += delay_in_seconds

      puts "Scheduling asset discovery of: #{ticker_symbol}"

      Global::Assets::DiscoveryJob.perform_in(current_delay.seconds, ticker_symbol)
    end

    puts 'Done!'
  end
end
