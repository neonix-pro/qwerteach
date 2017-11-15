require 'rails_helper'

RSpec.describe TeachersReport, type: :report do
  subject { TeachersReport.run(start_date: start_date, end_date: end_date) }
  let(:result) { subject.result }

  describe 'Client Data' do
    let!(:teacher) { create(:teacher) }
    let(:lesson_date) { Time.parse('2017-01-02') }

    let!(:lesson) { Timecop.freeze(lesson_date) { create(:lesson, :paid, teacher: teacher) } }

    let(:start_date) { '2017-01-01' }
    let(:end_date) { '2017-01-20' }


    it 'returns entity with client data' do
      expect(subject).to be_valid
      expect(result.first.as_json.symbolize_keys).to include(
        id: teacher.id,
        first_name: teacher.firstname,
        last_name: teacher.lastname
      )
      expect(result.first.last_seen).to be_within(1.second).of 1.day.ago
    end
  end

  describe 'Metrics' do
    let(:first_teacher) { create(:teacher) }
    let(:second_teacher) { create(:teacher) }

    let(:first_student) { create(:student) }
    let(:second_student) { create(:student) }
    let(:third_student) { create(:student) }

    let!(:yan_lessons) do
      [
        Timecop.freeze(Time.parse('2017-01-02').midday) { create(:lesson, :today, :paid, teacher: first_teacher, student: first_student) },
        Timecop.freeze(Time.parse('2017-01-03').midday) { create(:lesson, :today, :paid, teacher: first_teacher, student: first_student, ) }
      ]
    end

    let!(:feb_lessons) do
      [
        Timecop.freeze(Time.parse('2017-02-02').midday) { create(:lesson, :today, :paid, teacher: second_teacher, student: second_student) },
        Timecop.freeze(Time.parse('2017-02-03').midday) { create(:lesson, :today, :paid, teacher: second_teacher, student: second_student) }
      ]
    end

    let!(:march_lessons) do
      [
        Timecop.freeze(Time.parse('2017-03-02').midday) { create(:lesson, :today, :paid, teacher: first_teacher, student: third_student) },
        Timecop.freeze(Time.parse('2017-03-03').midday) { create(:lesson, :today, :paid, teacher: first_teacher, student: third_student) }
      ]
    end

    let(:start_date) { '2017-01-01' }
    let(:end_date) { '2017-02-20' }

    describe 'Lessons in period' do

      it 'returns teacher lessons count' do
        expect(subject).to be_valid
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_teacher.id,
          lessons_count: 2
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_teacher.id,
          lessons_count: 2
        )
      end

      it 'returns client lessons amount' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_teacher.id,
          lessons_amount: yan_lessons.sum(&:price)
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_teacher.id,
          lessons_amount: feb_lessons.sum(&:price)
        )
      end
    end

    describe 'All lessons' do

      it 'returns total client lessons count' do
        expect(result.first.as_json.symbolize_keys).to include(
            id: first_teacher.id,
            total_lessons_count: 4
          )
        expect(result[1].as_json.symbolize_keys).to include(
            id: second_teacher.id,
            total_lessons_count: 2
          )
      end

      it 'returns client total lessons amount' do
        expect(result.first.as_json.symbolize_keys).to include(
            id: first_teacher.id,
            total_lessons_amount: (yan_lessons + march_lessons).sum(&:price)
          )
        expect(result[1].as_json.symbolize_keys).to include(
            id: second_teacher.id,
            total_lessons_amount: feb_lessons.sum(&:price)
          )
      end
    end

    describe 'Students in period' do
      it 'returns teacher students count' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_teacher.id,
          students_count: 1
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_teacher.id,
          students_count: 1
        )
      end
    end

    describe 'All Students' do
      it 'returns total teacher student count' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_teacher.id,
          total_students_count: 2
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_teacher.id,
          total_students_count: 1
        )
      end
    end

    describe 'First lesson' do
      it 'returns first teacher lesson date' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_teacher.id,
          first_lesson_date: be_within(1.second).of(yan_lessons.first.time_start)
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_teacher.id,
          first_lesson_date: be_within(1.second).of(feb_lessons.first.time_start)
        )
      end
    end

    describe 'Last lesson' do
      it 'returns last teacher lesson date' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_teacher.id,
          last_lesson_date: be_within(1.second).of(march_lessons.last.time_start)
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_teacher.id,
          last_lesson_date: be_within(1.second).of(feb_lessons.last.time_start)
        )
      end
    end
  end

  describe 'Pagination' do
    let!(:teachers) { create_list(:teacher, 10) }
    let!(:lessons) do
      (Date.parse('2017-01-01')..Date.parse('2017-01-10')).map.with_index do |date, i|
        teacher = teachers[i]
        Timecop.freeze(date.midday) { create_list(:lesson, 2, :paid, :today, teacher: teacher) }
      end
    end

    subject { TeachersReport.run(start_date: '2017-01-01', end_date: '2017-01-10', per_page: 5, page: page) }

    context 'The first page' do
      let(:page) { 1 }

      it 'returns first 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:id)).to eq(teachers[0..4].map(&:id))
        expect(result.map(&:lessons_count)).to eq(Array.new(5) { 2 })
      end
    end

    context 'The second page' do
      let(:page) { 2 }

      it 'returns second 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:id)).to eq(teachers[5..9].map(&:id))
        expect(result.map(&:lessons_count)).to eq(Array.new(5) { 2 })
      end
    end
  end

  describe 'Ordering' do
    let(:first_teacher){ create(:teacher, last_seen: Time.current.midday) }
    let(:second_teacher){ create(:teacher, last_seen: 1.day.ago) }
    let(:third_teacher){ create(:teacher, last_seen: 2.day.ago) }

    let!(:first_lesson){ create :lesson, :today, :paid, time_start: 1.day.ago, teacher: first_teacher }
    let!(:second_lesson){ create :lesson, :today, :paid, time_start: Time.current.midday, teacher: second_teacher }
    let!(:third_lesson){ create :lesson, :today, :paid, time_start: 1.day.since, time_end: 25.hours.since, teacher: third_teacher }

    subject { TeachersReport.run(start_date: 2.days.ago.to_date, end_date: 2.days.since.to_date, order: order, direction: direction) }

    context 'First lesson date' do
      let(:order) { 'first_lesson_date' }
      context 'asc' do
        let(:direction) { 'asc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([first_teacher.id, second_teacher.id, third_teacher.id])
        end
      end
      context 'desc' do
        let(:direction) { 'desc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([third_teacher.id, second_teacher.id, first_teacher.id])
        end
      end
    end

    context 'Last lesson date' do
      let(:order) { 'last_lesson_date' }
      context 'asc' do
        let(:direction) { 'asc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([first_teacher.id, second_teacher.id, third_teacher.id])
        end
      end
      context 'desc' do
        let(:direction) { 'desc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([third_teacher.id, second_teacher.id, first_teacher.id])
        end
      end
    end

    context 'Last seen date' do
      let(:order) { 'last_seen' }
      context 'asc' do
        let(:direction) { 'asc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([third_teacher.id, second_teacher.id, first_teacher.id])
        end
      end
      context 'desc' do
        let(:direction) { 'desc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([first_teacher.id, second_teacher.id, third_teacher.id])
        end
      end
    end
  end
end