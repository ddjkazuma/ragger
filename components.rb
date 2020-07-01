module Components
  class Request
    attr_accessor :operation, :params
    def initialize(input_string)
      # 可能的input包括
      # 以:开头的操作符
      # 汉字
      params = input_string.split
      first_param = params[0].to_s
      if first_param.start_with? ":"
        @operation = first_param.partition(":").last.to_s.upcase
        @params = params.shift
      end
      @params = params
    end
    
    # 是否是操作请求
    def is_operation?
      @operation.nil?
    end
    
  end
  
  class Response
    SUCCESS = 0 # 绿色，适用于操作成功的场景，如查询单词成功，复习单词回答正确
    COMMON = 1 # 黄色，适用于普通的输入，如普通的提示
    NOTICE = 2 # 蓝色，适用于日常的提醒，如单词回答错误
    ERROR = 3 # 玫瑰红 发生一点小错误，
    FATAL = 4 # 红色 如程序被强行退出
    # 如何定义一个response，一个response可能由多条数据组成，每条
    def initialize(colorized_texts = [], should_terminate = false)
      @colorized_texts = colorized_texts
      @should_terminate = should_terminate
    end
    
    def should_terminate?
      @should_terminate
    end
    
    def terminate
      @should_terminate = true
      self
    end
    
    def to_s
      @colorized_texts.join("\n")
    end
  end
  
  module Colour
    def success_colorize(text)
      Rainbow(text).green
    end
    
    def common_colorize(text)
      Rainbow(text).yellow
    end
    
    def notice_colorize(text)
      Rainbow(text).blue
    end
    
    def error_colorize(text)
      Rainbow(text).magenta
    end
    
    def fatal_colorize(text)
      Rainbow(text).red
    end
    
  end
  
end