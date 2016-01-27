# Copyright 2016 Ryan Moore
# Contact: moorer@udel.edu
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

class Card
  include Const

  attr_accessor :efactor, :interval, :review_step, :num_reviews

  def initialize
    @efactor = 2.5
    @num_reviews = 0
    @review_step = 0
    @interval = update_interval
  end

  def update ease
    abort "ASSERTION ERROR" unless ease >= AGAIN && ease <= EASY

    self.num_reviews += 1

    $stderr.print "Old interval #{self.interval}, "

    if ease == AGAIN
      self.review_step = 0
    else
      self.review_step += 1
      update_efactor ease
    end

    update_interval

    $stderr.printf "Total reviews: %s, Review step: %s, Ease: %s, New Interval: %s\n",
                   self.num_reviews,
                   self.review_step,
                   EASE[ease],
                   self.interval
  end



  def update_efactor ease
    new_efactor =
      self.efactor + (0.1 - (5 - ease) * (0.08 + (5 - ease) * 0.02))

    if new_efactor < 1.3
      self.efactor = 1.3
    else
      self.efactor = new_efactor
    end
  end

  def next_interval review_step
    abort "ASSERTION ERROR" unless review_step >= 0

    if review_step.zero?
      0
    elsif review_step == 1
      1
    else
      next_interval(review_step-1) * self.efactor
    end
  end

  def update_interval
    self.interval = next_interval self.review_step
  end
end
