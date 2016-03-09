require './disjointed_interval.rb'

describe DisjointedInterval do
  before(:all) { @dj = DisjointedInterval.new }

  describe '#add' do
    describe 'when the interval is invalid' do
      before { @dj.state = [] }

      describe 'when to == from' do
        it 'raises an exception' do
          expect { @dj.add(1,1) }.to raise_error(RangeError)
        end
      end

      describe 'when from < to' do
        it 'raises an exception' do
          expect { @dj.add(2,1) }.to raise_error(RangeError)
        end
      end
    end

    describe 'when state is empty' do
      before { @dj.state = [] }

      it 'returns a state with a pair that has the from and to values' do
        @dj.add(1, 2)

        expect(@dj.state).to eq([[1, 2]])
      end
    end

    describe 'when there exists only one interval' do
      before { @dj.state = [[3,5]] }

      describe 'when from < fst_start'  do
        before { @from = 1 }

        describe 'when to < fst_start' do
          it 'inserts the new interval before the current interval' do
            @dj.add(@from, 2)

            expect(@dj.state).to eq([[1,2], [3,5]])
          end
        end

        describe 'when to == fst_start' do
          it 'prepends fst to include from' do
            @dj.add(@from, 3)

            expect(@dj.state).to eq([[1,5]])
          end
        end

        describe 'when to > fst_start && to < fst_end' do
          it 'prepends fst to include from' do
            @dj.add(@from, 4)

            expect(@dj.state).to eq([[1,5]])
          end
        end

        describe 'when to == fst_end' do
          it 'prepends fst to include from' do
            @dj.add(@from, 5)

            expect(@dj.state).to eq([[1,5]])
          end
        end

        describe 'when to > fst_end' do
          it 'appends fst to include to' do
            @dj.add(@from, 6)

            expect(@dj.state).to eq([[1, 6]])
          end
        end
      end

      describe 'when from == fst_start' do
        before { @from = 3 }

        describe 'when to > fst_start && to < fst_end' do
          it 'does not change fst' do
            @dj.add(@from, 4)

            expect(@dj.state).to eq([[3,5]])
          end
        end

        describe 'when to == fst_end' do
          it 'does not change fst' do
            @dj.add(@from, 4)

            expect(@dj.state).to eq([[3,5]])
          end
        end

        describe 'when to > fst_end' do
          it 'appends fst to include to' do
            @dj.add(@from, 6)

            expect(@dj.state).to eq([[3, 6]])
          end
        end
      end

      describe 'when from > fst_start && from < fst_end' do
        before { @from = 4 }

        describe 'when to == fst_end' do
          it 'does not change fst' do
            @dj.add(@from, 5)

            expect(@dj.state).to eq([[3,5]])
          end
        end

        describe 'when to > fst_end' do
          it 'appends fst to include to' do
            @dj.add(@from, 6)

            expect(@dj.state).to eq([[3, 6]])
          end
        end
      end

      describe 'when from == fst_end' do
        before { @from = 5 }

        describe 'when to > fst_end' do
          it 'appends fst to include to' do
            @dj.add(@from, 6)

            expect(@dj.state).to eq([[3, 6]])
          end
        end
      end

      describe 'when from > fst_end' do
        before { @from = 6 }

        it 'inserts the new interval after the current interval' do
          @dj.add(@from, 7)

          expect(@dj.state).to eq([[3,5], [6,7]])
        end
      end
    end

    describe 'when the state has two intervals' do
      before { @dj.state = [[3, 4], [5, 6]] }

      describe 'adding interval 1, 5' do
        it 'combines the interval to be 1, 6' do
          @dj.add(1, 5)

          expect(@dj.state).to eq([[1, 6]])
        end
      end
    end
  end

  describe '#remove_inclusive' do
    describe 'when the interval is invalid' do
      before { @dj.state = [] }

      describe 'when from < to' do
        it 'raises an exception' do
          expect { @dj.remove_inclusive(2,1) }.to raise_error(RangeError)
        end
      end
    end

    describe 'when state is empty' do
      before { @dj.state = [] }

      it 'returns the same empty state' do
        @dj.remove_inclusive(1, 2)

        expect(@dj.state).to eq([])
      end
    end

    describe 'when there exists only one interval' do
      before { @dj.state = [[3,5]] }

      describe 'when from < fst_start' do
        before { @from = 1 }

        describe 'when to < fst_start' do
          it 'does not change fst' do
            @dj.remove_inclusive(@from, 2)

            expect(@dj.state).to eq([[3,5]])
          end
        end

        describe 'when to == fst_start' do
          it 'modifies fst_start to to + 1' do
            @dj.remove_inclusive(@from, 3)

            expect(@dj.state).to eq([[4, 5]])
          end
        end

        describe 'when to > fst_start && to < fst_end' do
          it 'modifies fst_start to to + 1 and removes it cause start == end' do
            @dj.remove_inclusive(@from, 4)

            expect(@dj.state).to eq([])
          end
        end

        describe 'when to == fst_end' do
          it 'removes fst and state becomes empty' do
            @dj.remove_inclusive(@from, 5)

            expect(@dj.state).to eq([])
          end
        end

        describe 'when to > fst_end' do
          it 'removes fst and state becomes empty' do
            @dj.remove_inclusive(@from, 6)

            expect(@dj.state).to eq([])
          end
        end
      end

      describe 'when from == fst_start' do
        before { @from = 3 }

        describe 'when to > fst_start && to < fst_end' do
          it 'modifies fst_start to to + 1 and removes it cause start == end' do
            @dj.remove_inclusive(@from, 4)

            expect(@dj.state).to eq([])
          end
        end

        describe 'when to == fst_end' do
          it 'removes fst and state becomes empty' do
            @dj.remove_inclusive(@from, 5)

            expect(@dj.state).to eq([])
          end
        end

        describe 'when to > fst_end' do
          it 'removes fst and state becomes empty' do
            @dj.remove_inclusive(@from, 6)

            expect(@dj.state).to eq([])
          end
        end
      end

      describe 'when from > fst_start && from < fst_end' do
        before { @from = 4 }

        describe 'when to == fst_end' do
          it 'modifies fst_start to from - 1 and removes it cause start == end' do
            @dj.remove_inclusive(@from, 5)

            expect(@dj.state).to eq([])
          end
        end

        describe 'when to > fst_end' do
          it 'modifies fst_start to from - 1 and removes it cause start == end' do
            @dj.remove_inclusive(@from, 5)

            expect(@dj.state).to eq([])
          end
        end
      end

      describe 'when from == fst_end' do
        before { @from = 5 }

        describe 'when to > fst_end' do
          it 'modifies fst_end to from - 1' do
            @dj.remove_inclusive(@from, 6)

            expect(@dj.state).to eq([[3, 4]])
          end
        end
      end

      describe 'when from > fst_end' do
        before { @from = 6 }

        it 'does not change fst' do
          @dj.remove_inclusive(@from, 7)

          expect(@dj.state).to eq([[3,5]])
        end
      end
    end
  end
end
