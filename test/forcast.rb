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

require "active_support/core_ext/numeric/time"
require_relative "../lib/lib_helper"

class Card
  attr_accessor :forcast, :reviewed_days
end

correct = Const::GOOD
miss = Const::AGAIN

forcast_steps = 15

cards = []
# Day loop
total_reviews = 0
total_new_cards = 0

years = 1

total_days = 0

skipped_days = []
total_skipped = 0

(365*years).times do |today| # day loop
  total_days = today+1

  if rand(1..7) == 1 # skip the day
    warn "Skipped day #{today}!"
    total_skipped += 1
    skipped_days << today
  else
    $stderr.print "#{today}: "
    #  review cards
    num_reviews = 0
    cards.each do |card|
      should_review = card.forcast.any? { |day| (day == today && !card.reviewed_days.include?(day)) || (skipped_days.include?(day) && !card.reviewed_days.include?(day)) }

      if should_review
        card.forcast.each do |day|
          if skipped_days.include?(day) && !card.reviewed_days.include?(day)
            card.reviewed_days << day
          end
        end
      end

      if should_review
        num_reviews += 1
        # study
        card.num_reviews += 1
        card.reviewed_days << today
        if rand < 0.1 # miss
          card.review_step = 0
          # warn "Day: #{today}"
          # warn "Missed card!"
          # warn "Old forcast: #{card.forcast.inspect}"
          # this card was missed
          # reset forcast
          interval = 0
          card.forcast = forcast_steps.times.map do |n|
            next_interval = card.next_interval(n).round
            day = today + interval + next_interval
            interval = next_interval

            day
          end

          # warn "New forcast: #{card.forcast.inspect}"
        end
      else # card was correct
        card.review_step += 1
        # card.forcast << (today + card.next_interval(card.review_step).round)
      end
    end

    $stderr.print "#{num_reviews} reviews, "
    total_reviews += num_reviews

    # add cards loop
    new_cards = rand(0..40)
    new_cards.times do
      card = Card.new
      card.reviewed_days = []
      interval = 0
      card.forcast = forcast_steps.times.map do |n|
        next_interval = card.next_interval(n).round
        day = today + interval + next_interval
        interval = next_interval

        day
      end

      cards << card
    end

    $stderr.print "#{new_cards} new cards\n"
    total_new_cards += new_cards
  end
end

$stderr.puts "Days: #{total_days}, skipped days: #{total_skipped}\ntotal cards added: #{total_new_cards}\ntotal reviews: #{total_reviews}\navg new per day: #{total_new_cards/total_days.to_f}\navg reviewed per day: #{total_reviews/total_days.to_f}"

forcasts = []
cards.each { |card| forcasts << card.forcast }

forcast_h =
  Hash.new(0).merge(forcasts.
                     flatten.
                     sort.
                     group_by(&:itself).
                     map { |day, arr| [day, arr.count] }.to_h)

(0..forcast_h.keys.max).each do |n|
  puts [n, forcast_h[n]].join ","
end

# xs, ys = forcasts.flatten.sort.group_by(&:itself).map { |day, arr| [day, arr.count] }.transpose

# xs.each_with_index do |x, i|
#   puts [x, ys[i]].join ","
# end
