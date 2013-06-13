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
    from = "2001-01-01"
    if Transaction.where(:owner => user).count > 0
      from = Transaction.order(Sequel.asc(:timestamp)).where(:owner => user).first.timestamp.strftime("%Y-%m-%d")
    end
    from
  end

  def self.last_transaction(user)
    to = Time.now.strftime("%Y-%m-%d")
    if Transaction.where(:owner => user).count > 0
      to = Transaction.order(Sequel.asc(:timestamp)).where(:owner => user).last.timestamp.strftime("%Y-%m-%d")
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
    self.sum >= 0 ? "pos" : "neg"
  end

  def determine_row
    self.sum >= 0 ? "success" : "error"
  end

  def determine_category
    self.category_id = self.sum > 0 ? 2 : bayesian_filtering
  end

  def bayesian_filtering
    words = self.name.split(' ')
    tot_prob = Array.new(Category.count,0)
    words.each do |word|
      word_appears = 0
      transactions = Transaction.count
      prob_per_cat = Array.new(Category.count,0)
      for id in 1..Category.count
        word_appears_in_category = 0
        transactions_in_category = Transaction.where(:category_id => id).count
        Transaction.where(:category_id => id).all.each do |transaction|
          if transaction.name.include? word
            word_appears_in_category += 1
          end
        end
        prob_per_cat[id-1] = word_appears_in_category.to_f/transactions_in_category.to_f
        word_appears += word_appears_in_category
      end
      for id in 0..(Category.count-1)
        if word_appears == 0 or transactions == 0
          tot_prob[id] = 0
          next
        end
        tot_prob[id] += (prob_per_cat[id].to_f/(word_appears.to_f/transactions.to_f))
      end
    end
    for id in 0..(Category.count-1)
      tot_prob[id] /= Category.count
    end

    tot_prob.uniq.length == 1 ? 1 : tot_prob.rindex(tot_prob.max)+1
  end

  def self.get_sum(cat_ids, from, to, user)
    sum = 0
    Transaction.where(:timestamp => from..to, :category_id => cat_ids, :owner => user).all.each do |t|
      sum += t.sum
    end
    return sum
  end

  def self.get_sum_year(year, cat_ids, from, to, user)
    sum = 0
    Transaction.where(:timestamp => from..to, :category_id => cat_ids, :owner => user).all.each do |t|
      if t.timestamp.year == year
        sum += t.sum
      end
    end
    return sum.to_i
  end

  def self.get_sum_month(month, cat_ids, from, to, user)
    sum = 0
    Transaction.where(:timestamp => from..to, :category_id => cat_ids, :owner => user).all.each do |t|
      if t.timestamp.month == month
        sum += t.sum
      end
    end
    return sum.to_i
  end

  def self.get_sum_month_year(year, month, cat_ids, from, to, user)
    sum = 0
    Transaction.where(:timestamp => from..to, :category_id => cat_ids, :owner => user).all.each do |t|
      if t.timestamp.year == year and t.timestamp.month == month
        sum += t.sum
      end
    end
    return sum.to_i
  end
end
