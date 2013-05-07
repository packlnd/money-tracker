require 'sequel'

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

	def determine_category
		if self.sum > 0
			self.category_id = 2
		elsif self.sum > -100
			self.category_id = 3
		elsif self.sum % 100 == 0 and 
			self.sum >= -500 and 
			self.sum <= -100
			self.category_id = 5
		else
			self.category_id = 1
		end
	end
end