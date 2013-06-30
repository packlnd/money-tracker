# -*- encoding : utf-8 -*-
class Import
  def self.handle_file(file_from_user, user)
    if file_from_user
      file = File.open(file_from_user[:tempfile]).each do |line|
        data = line.delete("\r").delete("\n").split("\t")
        t = Transaction.new
        t.timestamp = data[0].chomp()
        t.name = data[1].chomp()
        t.sum = data[2].chomp().delete(" ").gsub(',','.').to_f
        t.category_id = t.sum > 0 ? 3 : bayesian_filtering(t.name)
        t.owner = user
        t.save
      end
    end
  end

  def self.bayesian_filtering(name)
    words = name.split(' ')
    probability = Array.new(Category.count,0)

    words.each do |word|
      word_appears = 0
      transactions = Transaction.count
      probability_category = Array.new(Category.count,0)

      for id in 1..Category.count
        word_category = times_in_category(word, id)
        transactions_category = Transaction.where(category_id: id).count
        if transactions_category == 0 then next end
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

  def self.times_in_category(word, id)
    word_count = 0
    transactions_in_category = Transaction.where(category_id: id).count
    Transaction.where(category_id: id).all.each do |transaction|
      if transaction.name.include? word
        word_count += 1
      end
    end
    word_count
  end
end
