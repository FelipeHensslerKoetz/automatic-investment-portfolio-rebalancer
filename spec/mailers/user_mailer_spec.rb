require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe 'rebalance_notification_email' do
    let(:rebalance) { create(:rebalance) }
    let(:email) { 'felipehenssler@gmail.com' }

    subject { described_class.rebalance_notification_email(email, rebalance) }

    it 'renders the subject' do
      expect(subject.subject).to eq('Rebalance result')
    end

    it 'renders the receiver email' do
      expect(subject.to).to eq([email])
    end

    it 'renders the sender email' do
      expect(subject.from).to eq(['from@example.com'])
    end

    it 'assigns @rebalance' do
      expect(subject.body.encoded).to match(rebalance.id.to_s)
    end

    it 'renders the body' do
      expect(subject.body.encoded).to be_present
    end
  end
end
