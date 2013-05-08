# -*- encoding : utf-8 -*-
require 'sequel'
require 'pry'

DB.create_table? :transactions do
	primary_key :id
	Float :sum, null: false
	Time :timestamp, null: false, default: 0
	String :name, null: false, default: 0
	String :owner, null: false
	Integer :category_id, null: false
end

class Transaction < Sequel::Model
	many_to_one :category

	def determine_sum
		if self.sum >= 0
			return "pos"
		end
		return "neg"
	end

	def determine_row
		if self.sum >= 0
			return "success"
		end
		return "error"
	end

	def determine_category
		if self.sum > 0
			self.category_id = 2
		elsif self.name == "MÅNADSAVG BANKKORT"
			self.category_id = 1
		elsif self.sum > -100
			self.category_id = 3
		elsif self.sum % 100 == 0 and self.sum >= -500 and self.sum <= -100
			self.category_id = 5
		else
			self.category_id = 1
		end
	end

	def self.get_sum_year(year)
		sum = 0
		Transaction.all.each do |t|
			if t.timestamp.year == year
				sum += t.sum
			end
		end
		return sum.to_i
	end

	def self.get_sum_month(year, month)
		sum = 0
		Transaction.all.each do |t|
			if t.timestamp.year == year and t.timestamp.month == month
				sum += t.sum
			end
		end
		return sum.to_i
	end
end