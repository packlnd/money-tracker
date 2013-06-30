# -*- encoding : utf-8 -*-
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
    if self.sum >= 0 then "success" else "error" end
  end

  def self.get_sum(cat_ids, from, to, user)
    sum = 0
    Transaction.where(timestamp: from..to, category_id: cat_ids, owner: user).all.each do |t|
      sum += t.sum
    end
    return sum
  end

  def self.get_sum_year(year, cat_ids, from, to, user)
    sum = 0
    Transaction.where(timestamp: from..to, category_id: cat_ids, owner: user).all.each do |t|
      if t.timestamp.year == year
        sum += t.sum
      end
    end
    return sum.to_i
  end

  def self.get_sum_month(month, cat_ids, from, to, user)
    sum = 0
    Transaction.where(timestamp: from..to, category_id: cat_ids, owner: user).all.each do |t|
      if t.timestamp.month == month
        sum += t.sum
      end
    end
    return sum.to_i
  end

  def self.get_sum_month_year(year, month, cat_ids, from, to, user)
    sum = 0
    Transaction.where(timestamp: from..to, category_id: cat_ids, owner: user).all.each do |t|
      if t.timestamp.year == year and t.timestamp.month == month
        sum += t.sum
      end
    end
    return sum.to_i
  end
end
