# /Users/kazuma/.rvm/rubies/ruby-2.6.2/bin/ruby

require_relative 'mercenary'
require_relative 'database/model/dictionary'
# 复习
class Supervisor
  
  attr_accessor :subject, :words_batch, :configuration
  
    # 查询单词，返回的是单词的json对象
    def seek(word)
      dictionary = Dictionary.find_by(:name=>word)
      if dictionary.nil?
        # explanation = Mercenary.new('https://openapi.youdao.com/api','2f3a48a702316da0','gTzzXsjEpFX9wUd8Rrio5SXfgzlcqq56').search(word)
        explanation = Mercenary.new(@configuration).search(word)
        encoded_explanation = explanation.to_json
        # todo 需要将释义格式化，变为单条的释义，便于用户匹配
        new_dictionary = Dictionary.create(name:word,exp_cn:explanation)
        raise Exception,'插入数据失败' if new_dictionary.nil?
      else
        encoded_explanation = dictionary.exp_cn.to_json
      end
      encoded_explanation
    end
    
  
  def initialize(mercenary_config)
    @words_batch = get_words_batch.each
    @configuration = mercenary_config
  end


  # 获取当前批次所有需要复习的单词
  def get_words_batch
    unfinished_words = Dictionary.where("status > -1").to_a
    words_count = (unfinished_words.size / 2).floor
    return [] if words_count == 0
    # 每次获取一半的未完成的单词
    unfinished_words.sample(words_count)
  end
  
  # 获取当前的主题单词
  def export_subject
    # 迭代单词句柄
    @subject = @words_batch.next
    @subject.name
  end
  
  # 根据输入的单词释义与实际的单词释义对比
  def validate_answer(answer)
    # exps = JSON.parse(@subject.exp_cn)
    @subject.exp_cn.each do |element|
         _, vals_with_semicolon = element.split ". "
         # 分隔符多种作样,包括中文分号,中文逗号,中文顿号
         vals = vals_with_semicolon.split(/[；\s、，]/)
         # vals.each{|ele| puts ele; puts "字符串的长度是#{ele.length}"; puts "元素类型是#{ele.class}"}
         return true if vals.include?answer # 如果能找到对应的释义则返回true
    end
    false
  end
  

  
end
