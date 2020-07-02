require 'aasm'
require_relative 'components'
# 反应器，维护一个状态机
class Reactor
  
  include AASM
  include Components::Colour
  
  def initialize(supervisor)
    @supervisor = supervisor
    @summary = {successful: 0, failed: 0}
  end
  
  def on_start
    colorized_texts = [
      "即将开始复习单词",
      "请输入单词对应的释义来回答单词, 或输入对应的操作符来控制程序, 按回车键确认",
      ":EXIT) 退出程序 ",
      "是否确认输出<:YES/:NO>"
    ].map { |element| common_colorize(element) }
    Components::Response.new colorized_texts
  end
  
  
  def handle_preparing(request)
    operation = request.operation
    puts operation
    if operation == "NO"
      # 如果回答是N(NO)则直接放弃，退出程序
      abandon
      Components::Response.new.terminate
    elsif operation == "YES"
      # 如果回答是Y(YES)则可以开始复习，触发之后要检查一下当前是否有可供复习的词
      Components::Response.new [notice_colorize("没有可供复习的单词")] if @supervisor.get_words_batch.size == 0
      start #触发开始复习事件，状态变为复习中状态
      Components::Response.new [common_colorize(@supervisor.export_subject)] #先导出需要复习的单词
    else
      response_with_illegal_input
    end
  end
  
  def handle_reviewing(request)
    operation = request.operation
    if operation == "EXIT"
      Components::Response.new [error_colorize("退出程序")]
    else
      word = request.params[0]
      answer = @supervisor.validate_answer(word)
      if answer
        answer && @supervisor.subject.step_forward
        colorized_text = [success_colorize("回答正确")]
        @summary[:successful]+=1
      else
        colorized_text = [notice_colorize("回答错误, 其正确释义是: #{@supervisor.subject.exp_cn}")]
        @summary[:failed]+=1
      end
      begin
        colorized_text << common_colorize(@supervisor.export_subject)
        Components::Response.new colorized_text
      rescue StopIteration
        colorized_text << success_colorize("复习结束")
        colorized_text += summary
        Components::Response.new(colorized_text).terminate
      end
    end
  end
  
  def handle_finished
  
  end
  
  # 输入无法识别
  def response_with_illegal_input
    Components::Response.new([error_colorize("无法识别的输入")])
  end
  
  # 对复习结果进行总结
  def summary
    colorized_texts = [
      common_colorize("本次复习共完成#{@summary[:successful]+@summary[:failed]}个单词"),
      success_colorize("其中成功#{@summary[:successful]}个, ")+notice_colorize("失败#{@summary[:failed]}个")
    ]
  end
  
  def handle(request)
    send get_handle_method_by_state, request
  end
  
  # 根据当前状态获取操作方法
  def get_handle_method_by_state
    'handle_' + aasm_read_state.to_s
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



