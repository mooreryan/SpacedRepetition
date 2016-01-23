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

  attr_accessor :efactor, :interval, :review_cycle_num, :total_reviews

  def initialize
    @efactor = 2.5
    @total_reviews = 0
    @review_cycle_num = 0
    @interval = update_interval
  end

  def update ease
    abort "ASSERTION ERROR" unless ease >= AGAIN && ease <= EASY

    self.total_reviews += 1

    $stderr.print "Old interval #{self.interval}, "

    if ease == AGAIN
      self.review_cycle_num = 0
    else
      self.review_cycle_num += 1
      update_efactor ease
    end

    update_interval

    $stderr.printf "Total reviews: %s, Review cycle: %s, Ease: %s, New Interval: %s\n",
                   self.total_reviews,
                   self.review_cycle_num,
                   EASE[ease],
                   self.interval
  end

  private

  def update_efactor ease
    new_efactor =
      self.efactor + (0.1 - (5 - ease) * (0.08 + (5 - ease) * 0.02))

    if new_efactor < 1.3
      self.efactor = 1.3
    else
      self.efactor = new_efactor
    end
  end

  def next_interval review_cycle_num
    abort "ASSERTION ERROR" unless review_cycle_num >= 0

    if review_cycle_num.zero?
      0
    elsif review_cycle_num == 1
      1
    else
      next_interval(review_cycle_num-1) * self.efactor
    end
  end

  def update_interval
    self.interval = next_interval self.review_cycle_num
  end
end
