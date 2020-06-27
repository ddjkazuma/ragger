require 'rainbow'

class Response
  NORMAL = 0 # 正常返回
  EMPTY_WORDS = 1 # 暂时没有可以复习的单词
  ILLEGAL_INPUT = 2 # 无法识别的输入，请重试
  REVIEW_TERMED = 3 # 退出程序
  REVIEW_FINISHED = 4 # 复习完毕 退出程序
  WRONG_ANSWER = 5 # 回答错误
  
  attr_reader :state_code, :messages
  
  def initialize(status = NORMAL, messages = [])
    @state_code = status
    @messages = messages
  end
  
  # 是否是正常的的返回对象
  def abnormal?
    @state_code != NORMAL
  end
  
  
  def prepend(message)
    @messages.prepend message
    self
  end
  
  def append(message)
    @messages << message
    self
  end
  
  
  class << self
    def normal(messages)
      self.new(NORMAL,messages)
    end
    
    def empty_words
      self.new(EMPTY_WORDS, ["没有需要复习的单词"])
    end
    
    def illegal_input
      self.new(ILLEGAL_INPUT, ["无法识别的输入"])
    end
    
    def review_termed
      self.new(REVIEW_TERMED, ["退出程序"])
    end
    
    def review_finished
      self.new(REVIEW_FINISHED, ["复习结束"])
    end
    
  end
  
  def to_s
    raw = @messages.join("\n")
    case @state_code
    when NORMAL then
      Rainbow(raw).blue
    when ILLEGAL_INPUT then
      Rainbow(raw).yellow
    when EMPTY_WORDS then
      Rainbow(raw).orange
    when REVIEW_FINISHED then
      Rainbow(raw).green
    when REVIEW_TERMED then Rainbow(raw).red
    else
      Rainbow(raw).red
    end
  end

end