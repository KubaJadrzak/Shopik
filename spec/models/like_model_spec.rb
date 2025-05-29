require 'rails_helper'


RSpec.describe Like, type: :model do

  describe 'validations' do
    context 'uniqueness' do
      let(:user) { create(:user) }
      let(:rubit) { create(:rubit) }

      it 'allows a user to like a rubit once' do
        like = Like.create(user: user, rubit: rubit)
        expect(like).to be_valid
      end

      it 'does not allow a user to like the same rubit twice' do
        Like.create(user: user, rubit: rubit)
        duplicate_like = Like.new(user: user, rubit: rubit)

        expect(duplicate_like).not_to be_valid
        expect(duplicate_like.errors[:user_id]).to include('this rubbit was already liked')
      end
    end
  end
end
