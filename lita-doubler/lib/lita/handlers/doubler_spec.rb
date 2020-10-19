require 'spec_helper'

describe Lita::Handlers::Doubler, lita_handler: true do
    let(:robot){ Lita::Robot.new(registry) }
    
    subject{ describe_class.new(robot) }

    describe 'routing' do
        it { is_expected.to route('Lita double 2') }
        it { is_expected.to route('Lita double 22') }
        it { is_expected.to route('Lita double 4') }
        it { is_expected.to_not route('Lita double two') }
        it { is_expected.to_not route('Lita double le4') }
    end

    describe 'functionality' do
        describe ':double_number' do
            let(:n) { rand(1..100) }
            it 'returns double the input' do
                actual = subject.double_number n
                expected = n * 2
                expect(actual).to eq(expected)
            end
        end

        it 'doubles numbers when asked to' do
            send_message 'Lita double 2'
            expect(replies.last).to eq('2 + 2 = 4')
        end
    end
end