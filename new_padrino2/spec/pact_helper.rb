require 'pact/provider/rspec'

Pact.service_provider "new padrino2" do

  honours_pact_with 'new padrino1' do
    #配置pact文件路径
    pact_uri '../new_padrino1/spec/pacts/new_padrino1-new_padrino2.json'#配置本地契约文件
    #若使用pact_broker管理契约文件,则配置pact_broker的路径
    #pact_uri 'http://localhost:8080/pacts/provider/new_padrino2/consumer/new_padrino1/latest'
  end
end



Pact.provider_states_for "new padrino1" do

  provider_state "new_padrino2将返回string数据" do
    set_up do
    end
  end

  provider_state "new_padrino2将返回json数据" do
    set_up do
    end
  end


end