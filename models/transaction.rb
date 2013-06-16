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
      from = Transaction.order(Sequel.asc(:timestamp)).where(:owner => user).first.time_to_s
    end
    from
  end

  def self.last_transaction(user)
    to = Time.now.strftime("%Y-%m-%d")
    if Transaction.where(:owner => user).count > 0
      to = Transaction.order(Sequel.asc(:timestamp)).where(:owner => user).last.time_to_s
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

  def time_to_s
    self.timestamp.strftime("%Y-%m-%d")
  end

  def determine_sum
    if self.sum >= 0 then "pos" else "neg" end
  end

  def determine_row
    if self.sum >= 0 then "success" else "error" end
  end

  def determine_category
    self.category_id = self.sum > 0 ? 3 : bayesian_filtering
  end

  def bayesian_filtering
    words = self.name.split(' ')
    probability = Array.new(Category.count,0)

    words.each do |word|
      word_appears = 0
      transactions = Transaction.count
      probability_category = Array.new(Category.count,0)

      for id in 1..Category.count
        word_category = times_in_category(word, id)
        transactions_category = Transaction.where(category_id: id).count
        probability_category[id-1] = word_category/transactions_category.to_f
        word_appears += word_category
      end

      for id in 0..(Category.count-1)
        if word_appears == 0 or transactions == 0 then next end
        probability[id] += (probability_category[id]/(word_appears/transactions.to_f))
      end
    end

    for id in 0..(Category.count-1)
      probability[id] /= Category.count
    end

    if probability.uniq.length == 1 then 1 else (probability.rindex(probability.max) + 1) end
  end

  def times_in_category(word, id)
    word_count = 0
    transactions_in_category = Transaction.where(:category_id => id).count
    Transaction.where(:category_id => id).all.each do |transaction|
      if transaction.name.include? word
        word_count += 1
      end
    end
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
