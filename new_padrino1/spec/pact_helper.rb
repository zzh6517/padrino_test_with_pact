require 'pact/consumer/rspec'

Pact.service_consumer "new padrino1" do
  has_pact_with "new padrino2" do
    mock_service :new_padrino2 do
      port 3000
    end
  end
end
