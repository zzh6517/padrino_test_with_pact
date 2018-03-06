require 'httparty'
require 'uri'
require 'json'

class User < ActiveRecord::Base

#获取string数据的实例方法
  def load_producer_string
    url = URI::encode('http://localhost:3000/provider.string')
    puts url
    response = HTTParty.get(url)
    if response.success?
      puts "成功返回string数据"
      response.body
    else
      puts "返回string数据失败"
    end
  end

#获取json数据的实例方法
  def load_producer_json(city)
    url = URI::encode('http://localhost:3000/provider.json?city=' + "#{city}")
    puts url
    response = HTTParty.get(url)
    if response.success?
      puts "成功返回json数据"
      JSON.parse(response.body)
    else
      response.parsed_response
      puts "返回json数据失败"
    end
  end

#自定义处理得到的string数据
  def process_string_data(name = nil)
    data = load_producer_string
    "#{name}:" + data
  end

#自定义处理得到的json数据
  def process_json_data(params = '上海')
    city = "#{params}"
    data = load_producer_json(city)
  end

end
