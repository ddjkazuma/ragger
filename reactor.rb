require 'aasm'
require_relative 'response'
# 反应器，维护一个状态机
class Reactor
  
  include AASM
  
  def initialize(supervisor)
    @supervisor = supervisor
  end
  
  class << self
    def rotate
      loop do
        if block_given?
          input = Readline::readline("> ", true)
          response = yield input
          puts response
          break if response.abnormal?
        end
      end
    end

    
    def before_review_prompt
      %w[即将开始复习，复习开始后系统会逐个输出需要复习的英文单词，请输入其中文释义用以匹配该单词 复习过程中可输入"exit"退出复习，开始复习?(Y/N)].each do |line|
        puts line
      end
    end
  end
  
  def react_by_input(input)
    #根据输入来作出反应
    # 改版后的程序的输入会有以下几种可能
    # 1, yes
    # 1，no
    # 3, exit
    # 4, 其他单词
    case aasm_read_state
    when :preparing
      if input[0].upcase == "N"
        # 如果回答是N(NO)则直接放弃，退出程序
        abandon
        Response.review_termed
      elsif input[0].upcase == "Y"
        # 如果回答是Y(YES)则可以开始复习，触发之后要检查一下当前是否有可供复习的词
        if @supervisor.get_words_batch.size == 0
          return Response.empty_words
        end
        start #触发开始复习事件，状态变为复习中状态
        Response.normal [@supervisor.export_subject] #先导出需要复习的单词
      else
        Response.illegal_input
      end
    when :reviewing
      if input.upcase == 'EXIT'
        return Response.review_termed;
      end
      answer = @supervisor.validate_answer(input).tap do |answer|
        answer && @supervisor.subject.step_forward
      end
      text = answer ? "回答正确" : "回答错误, 正确释义是: #{@supervisor.subject.exp_cn}"
      begin
        subject_word = @supervisor.export_subject
        Response.normal [text, subject_word]
      rescue StopIteration
        Response.review_finished.prepend text
      end
    else
      Response.illegal_input
    end
  end
  
  
  aasm do
    state :preparing, initial: true
    state :reviewing
    state :finished
    
    # 开始复习
    event :start do
      transitions from: :preparing, to: :reviewing
    end
    
    # 在准备阶段放弃复习
    event :abandon do
      transitions from: :preparing, to: :finished
    end
    
    # 结束复习
    event :end_review do
      transitions from: :reviewing, to: :finished
    end
  
  end
end



