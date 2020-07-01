require "thor"
require 'readline'
require 'active_record'
require 'rainbow'
require_relative 'supervisor'
require_relative 'reactor'
require_relative 'components'

class Command < Thor
  Thor::Base
  def initialize(*params)
    super *params
    @configuration = YAML::load_file(__dir__+'/config.yml')
    db_connect @configuration['database']
    @supervisor = Supervisor.new(@configuration['youdao'])
  end
  
  
  desc "query WORD", "查询单词"
  
  def query(word)
    begin
      #fixme
      puts Rainbow(@supervisor.seek(word)).green
    rescue Exception
      puts Rainbow("无法找到单词释义，请确认单词有效").red
    end
  end
  
  desc "review", "开始复习单词"
  
  def review
    reactor = Reactor.new @supervisor
    puts reactor.on_start
    loop do
      input = Readline.readline(Rainbow("> ").green, true)
      request =  Components::Request.new input
      response = reactor.handle request
      puts response
      break if response.should_terminate?
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
  
  #todo 该交互命令行可以考虑做成模块化的东西
end


Command.start ARGV



