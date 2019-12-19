require 'pact_broker/api/resources/badge'
require 'pact_broker/badges/service'
require 'pact_broker/matrix/service'

module PactBroker
  module Api
    module Resources
      describe Badge do
        let(:path) { "/pacts/provider/provider/consumer/consumer/latest/badge" }
        let(:params) { {} }

        before do
          allow(PactBroker::Pacts::Service).to receive(:find_latest_pact).and_return(pact)
          allow(PactBroker::Verifications::Service).to receive(:find_latest_verification_for).and_return(verification)
          allow(PactBroker::Badges::Service).to receive(:pact_verification_badge).and_return("badge")
          allow(PactBroker::Verifications::Status).to receive(:new).and_return(verification_status)
        end

        let(:pact) { instance_double("PactBroker::Domain::Pact", consumer: consumer, provider: provider) }
        let(:consumer) { double('consumer') }
        let(:provider) { double('provider') }
        let(:verification) { double("verification") }
        let(:verification_status) { instance_double("PactBroker::Verifications::Status", to_sym: :verified) }


        subject { get path, params, {'HTTP_ACCEPT' => 'image/svg+xml'}; last_response }

        context "when enable_public_badge_access is false and the request is not authenticated" do
          before do
            PactBroker.configuration.enable_public_badge_access = false
            allow_any_instance_of(Badge).to receive(:authenticated?).and_return(false)
          end

          it "returns a 401" do
            expect(subject.status).to eq 401
          end
        end

        context "when enable_public_badge_access is false but the request is authenticated" do
          before do
            PactBroker.configuration.enable_public_badge_access = false
            allow_any_instance_of(Badge).to receive(:authenticated?).and_return(true)
          end

          it "returns a 200" do
            expect(subject.status).to eq 200
          end
        end

        context "when enable_public_badge_access is true" do

          before do
            PactBroker.configuration.enable_public_badge_access = true
          end

          it "retrieves the latest pact" do
            expect(PactBroker::Pacts::Service).to receive(:find_latest_pact)
            subject
          end

          it "retrieves the latest verification for the pact's consumer and provider" do
            expect(PactBroker::Verifications::Service).to receive(:find_latest_verification_for).with(consumer, provider, nil)
            subject
          end

          it "determines the pact's verification status based on the latest pact and latest verification" do
            expect(PactBroker::Verifications::Status).to receive(:new).with(pact, verification)
            subject
          end

          it "creates a badge" do
            expect(PactBroker::Badges::Service).to receive(:pact_verification_badge).with(pact, nil, false, :verified)
            subject
          end

          it "returns a 200 status" do
            expect(subject.status).to eq 200
          end

          it "does not allow caching" do
            expect(subject.headers['Cache-Control']).to eq 'no-cache'
          end

          it "returns the badge" do
            expect(subject.body).to eq "badge"
          end

          context "when the label param is specified" do
            let(:params) { {label: 'consumer'} }

            it "creates a badge with the specified label" do
              expect(PactBroker::Badges::Service).to receive(:pact_verification_badge).with(anything, 'consumer', anything, anything)
              subject
            end
          end

          context "when the initials param is true" do
            let(:params) { {initials: 'true'} }

            it "creates a badge with initials" do
              expect(PactBroker::Badges::Service).to receive(:pact_verification_badge).with(anything, anything, true, anything)
              subject
            end
          end

          context "when the pact is not found" do
            let(:pact) { nil }

            it "returns a 200 status" do
              expect(subject.status).to eq 200
            end
          end

          context "when retrieving the badge for the latest pact with a tag" do
            let(:path) { "/pacts/provider/provider/consumer/consumer/latest/prod/badge" }

            it "retrieves the latest verification for the pact's consumer and provider and specified tag" do
              expect(PactBroker::Verifications::Service).to receive(:find_latest_verification_for).with(anything, anything, 'prod')
              subject
            end
          end

          context "when retrieving the badge for a matrix row by tag" do
            before do
              allow(PactBroker::Matrix::Service).to receive(:find_for_consumer_and_provider_with_tags).and_return(row)
              allow(PactBroker::Verifications::Service).to receive(:find_by_id).and_return(verification)
            end

            let(:path) { "/matrix/provider/provider/latest/master/consumer/consumer/latest/prod/badge" }
            let(:row) { { verification_id: 1 } }


            it "looks up the matrix row" do
              expect(PactBroker::Matrix::Service).to receive(:find_for_consumer_and_provider_with_tags).with(
                hash_including(consumer_name: 'consumer',
                provider_name: 'provider',
                tag: 'prod',
                provider_tag: 'master'
              ))
              subject
            end

            context "when a matrix row is found" do
              context "when there is a verification_id" do
                it "looks up the verification" do
                  expect(PactBroker::Verifications::Service).to receive(:find_by_id).with(1)
                  subject
                end

                it "returns the badge" do
                  expect(subject.body).to eq "badge"
                end
              end

              context "when there is not a verification_id" do
                let(:row) { {} }

                it "does not look up the verification" do
                  expect(PactBroker::Verifications::Service).to_not receive(:find_by_id)
                  subject
                end

                it "returns the badge" do
                  expect(subject.body).to eq "badge"
                end
              end
            end

            context "when a matrix row is not found" do
              let(:row) { nil }

              it "does not look up the verification" do
                expect(PactBroker::Verifications::Service).to_not receive(:find_by_id)
                subject
              end

              it "returns the badge" do
                expect(subject.body).to eq "badge"
              end
            end
          end
        end
      end
    end
  end
end