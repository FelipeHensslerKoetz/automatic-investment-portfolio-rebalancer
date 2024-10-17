# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def rebalance_notification_email(email, rebalance)
    @rebalance = rebalance

    mail(to: email, subject: 'Rebalance result')
  end
end
