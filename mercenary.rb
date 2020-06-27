require 'digest'
require 'httparty'
require 'json'
require 'uuid'
# 佣兵 该类负责与有道词库的交互
class Mercenary
  def initialize(configuration)
    @app_key = configuration['app_key']
    @app_secret = configuration['app_secret']
    @app_url = configuration['api_url']
  end
  
  public
  # 查找一个单词
  def search(word)
    params = build_query_params(word)
    response = HTTParty.post(@app_url,body:params)
    raise Exception, 'get response from youdao error' if response.code != 200
    parsed_response = JSON.parse response.body
    raise Exception, 'error from youdao response' if parsed_response["errorCode"] != '0'
    raise Exception, 'explanation not found' if parsed_response['basic']['explains'].nil?
    #puts parsed_response["basic"]["explains"]
    # todo 部分词在errCode=0的时候没有basic部分，需要处理一下
    parsed_response['basic']['explains']
  end
  
  
  private
  # 构造面向有道api的查询参数
  def build_query_params(word)
    # salt = SecureRandom.hex(16)
    salt = UUID.generate
    cur_time = Time.now.to_i
    sign = create_sign(word, salt,cur_time)
    {
      :q => word,
      :from => 'zh-CHS',
      :to => 'en',
      :appKey => @app_key,
      :salt => salt,
      :sign => sign,
      :signType => 'v3',
      :curtime => cur_time
    }
  end
  
  # 构造有道api签名
  def create_sign(word, salt, cur_time)
    base_str = @app_key+word+salt+cur_time.to_s+@app_secret
    Digest::SHA256.hexdigest base_str
  end
  
end



