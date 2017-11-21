require 'rails_helper'

RSpec.describe Admin::LessonsController, type: :controller do
  describe 'Export' do
    login_admin

    context 'CSV' do
      render_views
      let!(:lessons) { create_list(:lesson, 3) }
      let(:lesson) { lessons.first }

      subject { CSV.new(response.body, headers: true, col_sep: ';', header_converters: :symbol).to_a }

      it 'returns lessons in csv format' do
        get :export, format: :csv
        expect(response).to have_http_status(200)
        expect(subject.size).to eq(3)
        expect(subject.first.to_h).to include({
          student: lesson.student.name,
          teacher: lesson.teacher.name,
          status: lesson.status,
          topic_group: lesson.topic_group.title,
          topic: lesson.topic.title,
          price: lesson.price.to_s,
          time_start: lesson.time_start.utc.iso8601
        })
      end
    end
  end
end
