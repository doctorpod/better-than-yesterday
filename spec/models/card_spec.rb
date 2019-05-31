require 'rails_helper'

RSpec.describe Card, type: :model do
  subject { Card.create! }

  let!(:item1) { subject.items.create! }
  let!(:item2) { subject.items.create! }
  let(:date) { Date.new(2000,1,20) }

  describe 'scores' do
    context 'No period summaries' do
      it 'today is zero' do
        expect(subject.score_today(date)).to eq('0.00')
      end

      it 'yesterday is zero' do
        expect(subject.score_yesterday(date)).to eq('0.00')
      end

      it 'average is zero' do
        expect(subject.recent_average(date)).to eq('0.00')
      end
    end

    context 'Missing period summaries' do
      before do
        PeriodSummary.create!(date: date - 2, score: 2, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 3, score: 4, card_id: subject.id, item_id: item2.id)
      end

      it 'today is zero' do
        expect(subject.score_today(date)).to eq('0.00')
      end

      it 'yesterday is zero' do
        expect(subject.score_yesterday(date)).to eq('0.00')
      end

      it 'average is 0.6 (6/10)' do
        expect(subject.reload.recent_average(date)).to eq('0.60')
      end
    end

    context 'Full set of period summaries' do
      before do
        PeriodSummary.create!(date: date - 0, score: 5, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 1, score: 6, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 2, score: 2, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 3, score: 2, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 4, score: 2, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 5, score: 2, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 6, score: 2, card_id: subject.id, item_id: item1.id)
        PeriodSummary.create!(date: date - 7, score: 4, card_id: subject.id, item_id: item2.id)
        PeriodSummary.create!(date: date - 8, score: 4, card_id: subject.id, item_id: item2.id)
        PeriodSummary.create!(date: date - 9, score: 4, card_id: subject.id, item_id: item2.id)
        PeriodSummary.create!(date: date - 10, score: 4, card_id: subject.id, item_id: item2.id)
        PeriodSummary.create!(date: date - 11, score: 4, card_id: subject.id, item_id: item2.id)
      end

      it 'today is 5' do
        expect(subject.score_today(date)).to eq('5.00')
      end

      it 'yesterday is 6' do
        expect(subject.score_yesterday(date)).to eq('6.00')
      end

      it 'average is 3' do
        expect(subject.recent_average(date)).to eq('3.00')
      end
    end
  end

  describe 'rewards' do
    before do
      PeriodSummary.create!(date: date - 0, score: todays_score, card_id: subject.id, item_id: item1.id)
      PeriodSummary.create!(date: date - 1, score: 2, card_id: subject.id, item_id: item1.id)
      PeriodSummary.create!(date: date - 2, score: 40, card_id: subject.id, item_id: item1.id)
    end

    context 'todays score smaller than yesterday and average' do
      let(:todays_score) { 1 }

      it 'no rewards' do
        expect(subject.rewards(date).size).to eq(0)
      end
    end

    context 'todays score between yesterday and average' do
      let(:todays_score) { 3 }

      it '1 reward' do
        expect(subject.rewards(date).size).to eq(1)
      end
    end

    context 'todays score greater than yesterday and average' do
      let(:todays_score) { 5 }

      it '2 rewards' do
        expect(subject.rewards(date).size).to eq(2)
      end
    end
  end
end
