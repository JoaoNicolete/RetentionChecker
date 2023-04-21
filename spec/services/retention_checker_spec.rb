# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetentionChecker do
  subject(:retention_checker) { described_class.new(plan: plan, date: date) }

  let(:plan) { 'standard' }

  before do
    allow(Date).to receive(:today).and_return Date.new(1997, 11, 28)
  end

  shared_examples 'raise error' do
    it 'raises an error' do
      expect { retention_checker.check_retention }.to raise_error(StandardError)
    end
  end

  shared_examples 'returns retain' do
    it 'returns retain' do
      expect(retention_checker.check_retention).to eq('retain')
    end
  end

  shared_examples 'returns delete' do
    it 'returns retain' do
      expect(retention_checker.check_retention).to eq('delete')
    end
  end

  shared_examples 'standard scenario' do
    context 'when we should retain the snapshot' do
      let(:date) { Date.today - 1 }

      it_behaves_like 'returns retain'

      context 'when its the last day to retain the snapshot' do
        let(:date) { Date.today - described_class::DAYS_TO_RETAIN.days }

        it_behaves_like 'returns retain'
      end

      context 'when passing the date as a stringt' do
        let(:date) { '27/11/1997' }

        it_behaves_like 'returns retain'
      end
    end

    context 'when we should not retain the snapshot' do
      let(:date) { Date.today - 50.days }

      it_behaves_like 'returns delete'
    end
  end

  shared_examples 'gold scenario' do
    context 'and we should retain' do
      let(:date) { (Date.today - 6.months).end_of_month.to_s }

      it_behaves_like 'returns retain'
    end

    context 'and we should delete' do
      let(:date) { (Date.today - 2.years).end_of_month.to_s }

      it_behaves_like 'returns delete'
    end
  end

  describe '#check_retention' do
    context 'when passing invalid data' do
      context 'when passing an invalid plan' do
        let(:plan) { 'invalid' }

        it_behaves_like 'raise error'
      end

      context 'when passing an invalid date' do
        let(:date) { 'not a date' }

        it_behaves_like 'raise error'

        context 'when passing a date in the future' do
          let(:date) { Date.today + 50.years }

          it_behaves_like 'raise error'
        end
      end
    end

    context 'when plan is standard' do
      include_examples 'standard scenario'
    end

    context 'when plan is gold' do
      let(:plan) { 'gold' }

      context 'when it is the last snapshot of the month' do
        include_examples 'gold scenario'
      end

      context 'when it is not the last snapshot of the month' do
        include_examples 'standard scenario'
      end
    end

    context 'when plan is platinum' do
      let(:plan) { 'platinum' }

      context 'when is the last snapshot of the year' do
        context 'and we should retain' do
          let(:date) { (Date.today - 3.years).end_of_year }

          it_behaves_like 'returns retain'
        end

        context 'and we should delete' do
          let(:date) { (Date.today - 9.years).end_of_year }

          it_behaves_like 'returns delete'
        end

        context 'when it is the last snapshot of the month' do
          include_examples 'gold scenario'
        end

        context 'when its not the last of the year or the last of the month' do
          include_examples 'standard scenario'
        end
      end
    end
  end
end
