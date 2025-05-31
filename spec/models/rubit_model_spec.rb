require 'rails_helper'

RSpec.describe Rubit, type: :model do
  let(:rubit) { create(:rubit) }
  let!(:other_rubit) { create(:rubit) }
  let!(:child_rubit) { create(:rubit, parent_rubit: rubit, content: 'This is child Rubit') }
  let!(:other_child_rubit) { create(:rubit, parent_rubit: other_rubit, content: 'This is other child Rubit') }

  describe 'associations' do
    context 'child_rubits' do
      it 'returns only child rubits of a given rubit' do
        expect(rubit.child_rubits).to include(child_rubit)
        expect(rubit.child_rubits).not_to include(other_child_rubit)
      end
    end
    context 'parent_rubits' do
      it 'returns only parent rubits of a given child rubit' do
        expect(child_rubit.parent_rubit).to eq(rubit)
        expect(child_rubit.parent_rubit).to_not eq(other_rubit)
      end
    end
  end

  describe 'scopes' do
    context 'child_rubits' do
      it 'returns all child_rubits' do
        child_rubits = Rubit.child_rubits
        expect(child_rubits).to include(child_rubit, other_child_rubit)
        expect(child_rubits).to_not include(rubit, other_rubit)
      end
    end
    context 'root_rubits' do
      it 'returns all root rubits' do
        root_rubits = Rubit.root_rubits
        expect(root_rubits).to_not include(child_rubit, other_child_rubit)
        expect(root_rubits).to include(rubit, other_rubit)
      end
    end
  end
end
