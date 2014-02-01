# -*- encoding : utf-8 -*-
require 'sequel'
DB = Sequel.connect('sqlite://database.db')
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

  def self.first_transaction(user)
    return get_first(user, Sequel.asc(:timestamp)) || "2001-01-01"
  end

  def self.last_transaction(user)
    return get_first(user, Sequel.desc(:timestamp)) || Time.now.strftime("%Y-%m-%d")
  end

  def self.get_first(user, sort_type)
    unless Transaction.where(owner: user).empty?
      return Transaction.order(sort_type).where(owner: user).first.date_to_s
    end
  end

  def date_to_s
    self.timestamp.strftime("%Y-%m-%d")
  end

  def determine_text_css
    if self.sum >= 0 then "pos" else "neg" end
  end

  def determine_row_css
    if self.sum >= 0 then "success" else "danger" end
  end

  def self.get_sum(cat_ids, from, to, user)
    sum = 0
    Transaction.where(timestamp: from..to, category_id: cat_ids, owner: user).all.each do |t|
      sum += t.sum
    end
    return sum.to_i
  end

  def self.get_transactions(year, month, categories, user)
    enddays = days_in_month(year, month)
    from = Time.new(year, month, 1)
    to = Time.new(year,month, enddays)
    return Transaction.order(Sequel.desc(:timestamp)).where(timestamp: from..to, category_id: categories, owner: user).all
  end

  def self.days_in_month(year, month)
    common = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    return 29 if month == 2 && Date.gregorian_leap?(year)
    common[month]
  end

  def self.get_sum_year(year, cat_ids, user)
    return get_sum(cat_ids, "#{year}-01-01", "#{year}-12-31", user)
  end

  def self.get_sum_year_month(year, month, cat_ids, user)
    unless month.to_s.length == 2 then month = "0#{month}" end
    return get_sum(cat_ids, "#{year}-#{month}-01", "#{year}-#{month}-31", user)
  end
end
