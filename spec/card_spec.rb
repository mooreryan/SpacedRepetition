require "spec_helper"

describe Card do
  let(:card) { Card.new }

  it { should respond_to :efactor }
  it { should respond_to :interval }
  it { should respond_to :review_step }
  it { should respond_to :num_reviews }

  describe "#update" do
    it "increments :num_reviews" do
      expect { card.update Const::GOOD }.
        to change { card.num_reviews }.from(0).to(1)
    end

    context "when ease is AGAIN" do
      before(:each) { card.update Const::AGAIN }

      it "sets review step to 0" do
        expect(card.review_step).to be_zero
      end

      it "does not change the efactor" do
        expect { card.update Const::AGAIN }.
          to_not change { card.efactor }
      end

      it "sets interval to 0" do
        expect(card.interval).to be_zero
      end
    end

    context "when ease is anything else" do
      before(:each) { card.update Const::GOOD }

      it "increments :review_step" do
        expect { card.update Const::GOOD }.
          to change { card.review_step }.by 1
      end

      it "changes the interval" do
        expect { card.update Const::GOOD }.
          to change { card.interval }
      end

      context "when ease is HARD" do
        it "decreases the :efactor" do
          old_efactor = card.efactor
          card.update Const::HARD
          new_efactor = card.efactor

          expect(new_efactor).to be < old_efactor
        end
      end

      context "when ease is GOOD" do
        it "does not change the :efactor" do
          expect { card.update Const::GOOD }.
            not_to change { card.efactor }
        end
      end

      context "when ease is EASY" do
        it "increases the :efactor" do
          old_efactor = card.efactor
          card.update Const::EASY
          new_efactor = card.efactor

          expect(new_efactor).to be > old_efactor
        end
      end
    end
  end
end
