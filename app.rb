require "thor"
require 'readline'
require 'active_record'
require 'rainbow'
require_relative 'supervisor'
require_relative 'reactor'

class Ragger < Thor
  def initialize(*params)
    super *params
    @configuration = YAML::load_file(__dir__+'/config.yml')
    db_connect @configuration['database']
    @supervisor = Supervisor.new(@configuration['youdao'])
  end
  
  
  desc "query WORD", "查询单词"
  
  def query(word)
    # begin
      #fixme
      puts @supervisor.seek(word)
    # rescue Exception
    #   puts Rainbow("无法找到单词释义，请确认单词有效").red
    # end
  end
  
  desc "review", "开始复习单词"
  
  def review
    begin
      reactor = Reactor.new @supervisor
      Reactor.before_review_prompt
      Reactor.rotate do |input|
        reactor.react_by_input input
      end
    rescue Interrupt
      # 优雅退出
      puts "退出程序"
    end
  end
  
  private
  
  def db_connect(db_config)
    ActiveRecord::Base.establish_connection(
      adapter: 'mysql2',
      host: db_config['host'],
      username: db_config['user'],
      password: db_config['password'],
      database: db_config['database'],
    )
  end
end

Ragger.start ARGV



