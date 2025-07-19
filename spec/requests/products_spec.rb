#frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsController, type: :request do
  describe 'GET /products' do
    let!(:product1) { create(:product, title: 'Product A') }
    let!(:product2) { create(:product, title: 'Product B') }

    it 'renders index and displays products' do
      get products_path

      expect(response).to have_http_status(:ok)

      expect(response.body).to include('Product A')
      expect(response.body).to include('Product B')
    end
  end
end
