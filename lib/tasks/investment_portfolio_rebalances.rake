# frozen_string_literal: true

require 'csv'

SCALE_OF_NUMBER_OF_ASSETS = [2..50, 51..100, 101..150, 151..200, 201..250].freeze # 5

SCALE_OF_QUANTITY_OF_ASSETS = [2..50, 51..100, 101..150, 151..200, 201..250].freeze # 5 

SCALE_OF_ALLOCATION_WEIGHTS = %w[random uniform].freeze # 2

REBALANCE_KINDS = %w[default_rebalance default_rebalance_with_deposit default_rebalance_with_withdrawal contribution_rebalance].freeze

SCALE_OF_REBALANCE_AMOUNT = [1..33, 34..66, 67..99, 100..200].freeze

SCALE_REBALANCE_WITHDRAWAL_AMOUNT = [1..33, 34..66, 67..99].freeze

namespace :investment_portfolio_rebalances do
  desc 'TODO'
  task simulations: :environment do
    @asset_ids = Asset.pluck(:id)
    @user_id = 1
    @created_investment_portfolios_count = 0
    @csv_file = CSV.open('investment_portfolio_rebalances.csv', 'wb', col_sep: ';')

    @csv_file << %w[scale_of_number_of_assets
                    scale_of_quantity_of_assets
                    scale_of_allocation_weights
                    rebalance_kind
                    scale_of_rebalance_amount
                    investment_portfolio_id
                    rebalance_order_id
                    rebalance_id
                    current_variation_percentage_total_sum
                    projected_variation_percentage_total_sum
                    variation_percentage_reduction
                    execution_time_in_seconds]

    def distribute_allocation_randomly(random_number_of_assets)
      random_values = Array.new(random_number_of_assets) { rand.to_d }

      sum = random_values.sum

      distribution = random_values.map { |random_value| ((random_value / sum) * 100.to_d) }

      difference = 100.to_d - distribution.sum
      distribution[-1] = (distribution[-1] + difference).to_d

      distribution
    end

    def distribute_allocation_uniformly(random_number_of_assets)
      average_value = (100.to_d / random_number_of_assets.to_d)

      distribution = Array.new(random_number_of_assets, average_value)

      difference = 100.to_d - distribution.sum
      distribution[-1] = (distribution[-1] + difference).to_d

      distribution
    end

    def create_random_investment_portfolio(random_investment_portfolio_params)
      allocation_weight_kind = random_investment_portfolio_params[:scale_of_allocation_weight]
      random_number_of_assets = rand(random_investment_portfolio_params[:scale_of_number_of_assets])
      random_asset_ids = @asset_ids.sample(random_number_of_assets)

      asset_details = random_asset_ids.map do |random_asset_id|
        {
          asset_id: random_asset_id,
          quantity: rand(random_investment_portfolio_params[:scale_of_quantity_of_assets])
        }
      end

      investment_portfolio = InvestmentPortfolio.create!(user_id: @user_id,
                                                         name: "Random Investment Portfolio #{SecureRandom.uuid}")

      distribution = if allocation_weight_kind == 'random'
                       distribute_allocation_randomly(random_number_of_assets)
                     else
                       distribute_allocation_uniformly(random_number_of_assets)
                     end

      binding.pry if distribution.sum != 100 || distribution.any?(&:negative?)

      asset_details.each_with_index do |asset_detail, index|
        InvestmentPortfolioAsset.create!(
          investment_portfolio_id: investment_portfolio.id,
          asset_id: asset_detail[:asset_id],
          quantity: asset_detail[:quantity],
          target_allocation_weight_percentage: distribution[index]
        )
      rescue StandardError => e
        binding.pry
      end

      investment_portfolio.save!

      @created_investment_portfolios_count += 1

      puts "Random investment portfolio created! - #{@created_investment_portfolios_count}"

      investment_portfolio
    end

    def create_and_schedule_rebalance_order(investment_portfolio:, amount:, rebalance_kind:)
      rebalance_order = RebalanceOrder.create!(investment_portfolio:, user_id: @user_id, kind: 'default', amount: 0,
                                               scheduled_at: Time.zone.today)
      rebalance_order.schedule!
      rebalance_order
    end

    def create_process_and_write_rebalance_results_to_csv(investment_portfolio, investment_portfolio_simulation_params)
      investment_portfolio_projected_total_value = System::Rebalances::CurrentInvestmentPortfolioStateCalculatorService.call(
        investment_portfolio:,
        amount: 0,
        rebalance_kind: 'default'
      )[:investment_portfolio_projected_total_value]

      REBALANCE_KINDS.each do |rebalance_kind|
        case rebalance_kind
        when 'default_rebalance', 'default_rebalance_with_deposit', 'default_rebalance_with_withdrawal'
          if rebalance_kind == 'default_rebalance'
            rebalance_order = RebalanceOrder.create!(investment_portfolio:, user_id: @user_id, kind: 'default', amount: 0,
                                                     scheduled_at: Time.zone.today)
            rebalance_order.schedule!
            System::Rebalances::CalculatorService.call(rebalance_order_id: rebalance_order.id)
            rebalance = Rebalance.find_by(rebalance_order_id: rebalance_order.id)

            raise StandardError, "Rebalance not found for rebalance_order_id: #{rebalance_order.id}" if rebalance.blank?

            current_variation_percentage_total_sum = rebalance.current_investment_portfolio_state.sum do |asset_state|
              asset_state['current_variation_percentage'].to_d.abs.truncate(2)
            end
            projected_variation_percentage_total_sum = rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum do |asset_state|
              asset_state['current_variation_percentage'].to_d.abs.truncate(2)
            end

            reduced_variation_percentage = (100 * (current_variation_percentage_total_sum - projected_variation_percentage_total_sum) / current_variation_percentage_total_sum).truncate(2).to_s.gsub('.', ',')

            @csv_file << [
              investment_portfolio_simulation_params[:scale_of_number_of_assets].to_s,
              investment_portfolio_simulation_params[:scale_of_quantity_of_assets].to_s,
              investment_portfolio_simulation_params[:scale_of_allocation_weight].to_s,
              rebalance_kind,
              '-',
              investment_portfolio.id,
              rebalance_order.id,
              rebalance.id,
              current_variation_percentage_total_sum.to_s.gsub('.', ','),
              projected_variation_percentage_total_sum.to_s.gsub('.', ','),
              reduced_variation_percentage,
              rebalance.execution_time_in_seconds.truncate(2).to_s.gsub('.', ',')
            ]
          else
            scale = rebalance_kind == 'default_rebalance_with_deposit' ? SCALE_OF_REBALANCE_AMOUNT : SCALE_REBALANCE_WITHDRAWAL_AMOUNT
            scale.each do |scale_of_rebalance_amount|
              amount = investment_portfolio_projected_total_value * (rand(scale_of_rebalance_amount).to_d / 100.to_d)
              amount = amount * -1 if rebalance_kind == 'default_rebalance_with_withdrawal'

              rebalance_order = RebalanceOrder.create!(investment_portfolio:, user_id: @user_id, kind: 'default', amount: amount,
                                                       scheduled_at: Time.zone.today)
              rebalance_order.schedule!
              System::Rebalances::CalculatorService.call(rebalance_order_id: rebalance_order.id)
              rebalance = Rebalance.find_by(rebalance_order_id: rebalance_order.id)

              raise StandardError, "Rebalance not found for rebalance_order_id: #{rebalance_order.id}" if rebalance.blank?

              current_variation_percentage_total_sum = rebalance.current_investment_portfolio_state.sum do |asset_state|
                asset_state['current_variation_percentage'].to_d.abs.truncate(2)
              end
              projected_variation_percentage_total_sum = rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum do |asset_state|
                asset_state['current_variation_percentage'].to_d.abs.truncate(2)
              end

              reduced_variation_percentage = (100 * (current_variation_percentage_total_sum - projected_variation_percentage_total_sum) / current_variation_percentage_total_sum).truncate(2).to_s.gsub('.', ',')

              @csv_file << [
                investment_portfolio_simulation_params[:scale_of_number_of_assets].to_s,
                investment_portfolio_simulation_params[:scale_of_quantity_of_assets].to_s,
                investment_portfolio_simulation_params[:scale_of_allocation_weight].to_s,
                rebalance_kind,
                scale_of_rebalance_amount,
                investment_portfolio.id,
                rebalance_order.id,
                rebalance.id,
                current_variation_percentage_total_sum.to_s.gsub('.', ','),
                projected_variation_percentage_total_sum.to_s.gsub('.', ','),
                reduced_variation_percentage,
                rebalance.execution_time_in_seconds.truncate(2).to_s.gsub('.', ',')
              ]
            end
          end
        when 'contribution_rebalance'
          SCALE_OF_REBALANCE_AMOUNT.each do |scale_of_rebalance_amount|
            amount = investment_portfolio_projected_total_value * (rand(scale_of_rebalance_amount).to_d / 100.to_d)

            rebalance_order = RebalanceOrder.create!(investment_portfolio:, user_id: @user_id, kind: 'contribution', amount: amount,
                                                     scheduled_at: Time.zone.today)
            rebalance_order.schedule!
            System::Rebalances::CalculatorService.call(rebalance_order_id: rebalance_order.id)
            rebalance = Rebalance.find_by(rebalance_order_id: rebalance_order.id)

            raise StandardError, "Rebalance not found for rebalance_order_id: #{rebalance_order.id}" if rebalance.blank?

            current_variation_percentage_total_sum = rebalance.current_investment_portfolio_state.sum do |asset_state|
              asset_state['current_variation_percentage'].to_d.abs.truncate(2)
            end
            projected_variation_percentage_total_sum = rebalance.projected_investment_portfolio_state_with_rebalance_actions.sum do |asset_state|
              asset_state['current_variation_percentage'].to_d.abs.truncate(2)
            end

            reduced_variation_percentage = (100 * (current_variation_percentage_total_sum - projected_variation_percentage_total_sum) / current_variation_percentage_total_sum).truncate(2).to_s.gsub('.', ',')

            @csv_file << [
              investment_portfolio_simulation_params[:scale_of_number_of_assets].to_s,
              investment_portfolio_simulation_params[:scale_of_quantity_of_assets].to_s,
              investment_portfolio_simulation_params[:scale_of_allocation_weight].to_s,
              rebalance_kind,
              scale_of_rebalance_amount,
              investment_portfolio.id,
              rebalance_order.id,
              rebalance.id,
              current_variation_percentage_total_sum.to_s.gsub('.', ','),
              projected_variation_percentage_total_sum.to_s.gsub('.', ','),
              reduced_variation_percentage,
              rebalance.execution_time_in_seconds.truncate(2).to_s.gsub('.', ',')
            ]
          end
        end
      end
    end

    SCALE_OF_ALLOCATION_WEIGHTS.each do |scale_of_allocation_weight|
      SCALE_OF_NUMBER_OF_ASSETS.each do |scale_of_number_of_assets|
        SCALE_OF_QUANTITY_OF_ASSETS.each do |scale_of_quantity_of_assets|
          investment_portfolio_simulation_params = {
              scale_of_allocation_weight:,
              scale_of_number_of_assets:,
              scale_of_quantity_of_assets:,
            }

            random_investment_portfolio = create_random_investment_portfolio(investment_portfolio_simulation_params)

            create_process_and_write_rebalance_results_to_csv(random_investment_portfolio, investment_portfolio_simulation_params)
        end
      end
    end

    @csv_file.close
    puts 'CSV file created!'
  end
end
