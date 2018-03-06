require 'spec_helper'
require 'pact_helper'

RSpec.describe User do

#初始化str_data
  let(:str_data) do
    "新年快乐"
  end

#初始化json_data
  let(:json_data) do
    {
      "城市" => "上海",
      "天气" => "晴",
      "温度" => "20度"
    }
  end

#初始化响应结果response
  let(:response) { double('Response', :success? => true, :body => str_data.to_s) }
  let(:response) { double('Response', :success? => true, :body => json_data.to_json) }


  describe '测试从new_padrino2得到str_data数据', :pact => true do

    before do
      new_padrino2.
        given("new_padrino2将返回string数据").
          upon_receiving("new_padrino2接受一个获取string数据的http请求").
            with(
                method: :get,
                path: '/provider.string',
            ).
            will_respond_with(
              status: 200,
              headers: { 'Content-Type' => 'text/html;charset=utf-8' },
              body: str_data
            )
    end

    it '期望能够从new_padrino2得到处理后的string数据' do
      expect(subject.load_producer_string).to eql(str_data)
    end
  end


  describe '测试从new_padrino2得到json_data数据', :pact => true do

    let(:city) { "上海" }

    before do
      new_padrino2.
        given("new_padrino2将返回json数据").
          upon_receiving("new_padrino2接受一个获取json数据的http请求").
            with(
                method: :get,
                path: '/provider.json',
                query: URI::encode('city=' + city)
            ).
            will_respond_with(
              status: 200,
              headers: { 'Content-Type' => 'application/json' },
              body: json_data
            )
    end

    it '期望能够从服务提供者处得到处理后的json数据' do
      expect(subject.process_json_data).to eql(json_data)
    end
  end

end
