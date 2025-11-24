# # frozen_string_literal: true

# require 'rails_helper'

# RSpec.describe Espago::ClientsController, type: :request do
#   let(:user) { create(:user) }
#   before do
#     sign_in user
#   end

#   describe 'GET espago/clients/new' do
#     let(:client) { create(:client) }
#     it 'returns http success' do
#       get espago_client_path(client)
#       expect(response).to have_http_status(:success)
#     end
#   end

#   describe 'POST /clients/:id/toggle_primary' do
#     context 'when user has an auto-renewing subscription, primary payment method and chooses different primary payment method' do
#       let!(:client) { create(:client, :primary, user: user) }
#       let!(:subscription) { create(:subscription, user: user, auto_renew: true) }
#       let!(:new_client) { create(:client, user: user, status: 'MIT') }

#       it 'switches primary payment method and doesnt change subscription auto-renew' do
#         expect do
#           patch toggle_primary_espago_client_path(new_client)
#         end.to change { new_client.reload.primary }
#           .from(false).to(true)

#         expect(subscription.reload.auto_renew).to eq(true)
#         expect(client.reload.primary).to eq(false)
#       end
#     end

#     context 'when user has primary payment method and doesnt have auto renew subscription' do
#       let!(:client) { create(:client, :primary, user: user) }
#       it 'disables primary payment method' do
#         expect do
#           patch toggle_primary_espago_client_path(client)
#         end.to change { client.reload.primary }
#           .from(true).to(false)

#         expect(client.reload.primary).to eq(false)
#       end
#     end

#     context 'when user has auto-renew subscription and disables primary payment method' do
#       let!(:client) { create(:client, :primary, user: user) }
#       let!(:subscription) { create(:subscription, user: user, auto_renew: true) }
#       it 'disables primary payment method and auto-renew subscription' do
#         expect do
#           patch toggle_primary_espago_client_path(client)
#         end.to change { client.reload.primary }
#           .from(true).to(false)

#         expect(subscription.reload.auto_renew).to eq(false)
#         expect(client.reload.primary).to eq(false)
#       end
#     end
#   end
#   describe 'GET /clients/:id/verify' do
#     context 'when client is CIT' do
#       let(:cit_client) { create(:client, user: user, status: 'CIT') }

#       it 'return http success' do
#         get verify_espago_client_path(cit_client)
#         expect(response).to have_http_status(:success)
#       end
#     end

#     context 'when client is not CIT' do
#       let(:not_cit_client) { create(:client, user: user, status: 'MIT') }
#       it 'redirects to account_path with an alert' do
#         get verify_espago_client_path(not_cit_client)

#         expect(response).to redirect_to(account_path)
#         follow_redirect!
#         expect(response.body).to include('We could not process your verification due to a technical issue')
#       end
#     end
#   end
# end
