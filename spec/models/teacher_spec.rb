require 'rails_helper'

RSpec.describe Teacher, type: :model do
  describe 'postulance_accepted' do
    let(:teacher){ create(:teacher, postulance_accepted: false) }

    context 'Postulations are not completed' do
      it 'does not allow to set postulance_accepted' do
        teacher.postulance_accepted = true
        expect(teacher.save).to eq(false)
        expect(teacher.errors.keys).to match_array([:postulance_accepted])
      end
    end

    context 'Postulations are completed' do
      it 'allows to set postulance_accepted' do
        expect(teacher.postulation).to receive(:completed?).and_return(true)
        teacher.postulance_accepted = true
        expect(teacher.save).to eq(true)
        expect(teacher.reload.postulance_accepted).to eq(true)
      end
    end

  end
end
