# -*- encoding : utf-8 -*-
require 'json'
class Graph
  def self.monthly_data(year, cat_ids, username)
    categories = Hash.new
    cat_ids.each do |cat_id|
      category = Hash.new
      cat = Category.get_category(cat_id)
      category["color"] = cat.color
      month = Hash.new
      (1..12).each do |m|
        month[m-1] = Transaction.get_sum_year_month(year, m, cat_id, username)
      end
      category["months"] = month.to_json
      categories[cat.name] = category.to_json
    end
    return categories.to_json
  end

  def self.pie_data(from, to, categories, username)
    categories = Hash.new
    category_ids.each do |cat_id|
      cat = Category.get_category(cat_id)
      category = Hash.new
      category["sum"] = Transaction.get_sum(cat.seq_id, from, to, username).to_i.abs
      category["color"] = cat.color
      categories[cat.name] = category.to_json
    end
    return categories.to_json
  end
end
