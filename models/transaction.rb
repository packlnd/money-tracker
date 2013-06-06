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

  def self.get_first_entry(user)
    from = "2001-01-01"
    if Transaction.where(:owner => user).count > 0
      from = Transaction.order(Sequel.desc(:timestamp)).where(:owner => user).first.timestamp.strftime("%Y-%m-%d")
    end
    from
  end

  def self.get_last_entry(user)
    to = Time.now.strftime("%Y-%m-%d")
    if Transaction.where(:owner => user).count > 0
      to = Transaction.order(Sequel.desc(:timestamp)).where(:owner => user).last.timestamp.strftime("%Y-%m-%d")
    end
    to
  end

  def self.handle_file(file_from_user, user)
      if file_from_user
        file = File.open(file_from_user[:tempfile]).each do |line|
          data = line.delete("\r").delete("\n").split("\t")
          transaction = Transaction.new
          transaction.timestamp = data[0].chomp()
          transaction.name = data[1].chomp()
          transaction.sum = data[2].chomp().delete(" ").gsub(',','.').to_f
          transaction.determine_category
          transaction.owner = user
          transaction.save
        end
      end
  end

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
    # If sum is positive we already know which category to put it in (for now).
    if self.sum > 0
      self.category_id = 2
      return
    end

    # Else we use bayesian filtering.
    words = self.name.split(' ')
    total_probability = Array.new(Category.count,0)

    words.each do |word|
      word_appears = 0
      transactions = Transaction.count
      probability_per_category = Array.new(Category.count,0)

      for id in 1..Category.count
        word_appears_in_category = 0
        transactions_in_category = Transaction.where(:category_id => id).count

        Transaction.where(:category_id => id).all.each do |transaction|
          if transaction.name.include? word
            word_appears_in_category += 1
          end
        end

        probability_per_category[id-1] = word_appears_in_category.to_f/transactions_in_category.to_f
        word_appears += word_appears_in_category
      end

      for id in 0..(Category.count-1)
        if word_appears == 0 or transactions == 0
          total_probability[id] = 0
          next          
        end
        total_probability[id] += (probability_per_category[id].to_f/(word_appears.to_f/transactions.to_f))
      end
    end

    for id in 0..(Category.count-1)
      total_probability[id] /= Category.count
    end
    self.category_id = total_probability.rindex(total_probability.max)+1
    puts total_probability
  end

  def self.get_sum_year(year, cat_ids, user)
    sum = 0
    Transaction.where(:category_id => cat_ids, :owner => user).all.each do |t|
      if t.timestamp.year == year
        sum += t.sum
      end
    end
    return sum.to_i
  end

  def self.get_sum_month(year, month, cat_ids, user)
    sum = 0
    Transaction.where(:category_id => cat_ids, :owner => user).all.each do |t|
      if t.timestamp.year == year and t.timestamp.month == month
        sum += t.sum
      end
    end
    return sum.to_i
  end
end
