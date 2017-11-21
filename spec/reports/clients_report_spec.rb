require 'rails_helper'

RSpec.describe ClientsReport, type: :report do
  subject { ClientsReport.run(start_date: start_date, end_date: end_date) }
  let(:result) { subject.result }

  describe 'Client Data' do
    let!(:student) { create(:student) }
    let(:lesson_date) { Time.zone.parse('2017-01-02') }

    let!(:lesson) { Timecop.freeze(lesson_date) { create(:lesson, :paid, student: student) } }

    let(:start_date) { '2017-01-01' }
    let(:end_date) { '2017-01-20' }


    it 'returns entity with client data' do
      expect(subject).to be_valid
      expect(result.first.as_json.symbolize_keys).to include(
        id: student.id,
        first_name: student.firstname,
        last_name: student.lastname
      )
      expect(result.first.last_seen).to be_within(5.seconds).of 1.day.ago
    end
  end

  describe 'Metrics' do
    let(:first_student) { create(:student) }
    let(:second_student) { create(:student) }

    let(:first_teacher) { create(:teacher) }
    let(:second_teacher) { create(:teacher) }
    let(:third_teacher) { create(:teacher) }

    let!(:yan_lessons) do
      [
        Timecop.freeze(Time.parse('2017-01-02').midday) { create(:lesson, :today, :paid, student: first_student, teacher: first_teacher) },
        Timecop.freeze(Time.parse('2017-01-03').midday) { create(:lesson, :today, :paid, student: first_student, teacher: first_teacher) }
      ]
    end

    let!(:feb_lessons) do
      [
        Timecop.freeze(Time.parse('2017-02-02').midday) { create(:lesson, :today, :paid, student: second_student, teacher: second_teacher) },
        Timecop.freeze(Time.parse('2017-02-03').midday) { create(:lesson, :today, :paid, student: second_student, teacher: second_teacher) }
      ]
    end

    let!(:march_lessons) do
      [
        Timecop.freeze(Time.parse('2017-03-02').midday) { create(:lesson, :today, :paid, student: first_student, teacher: third_teacher) },
        Timecop.freeze(Time.parse('2017-03-03').midday) { create(:lesson, :today, :paid, student: first_student, teacher: third_teacher) }
      ]
    end

    let(:start_date) { '2017-01-01' }
    let(:end_date) { '2017-02-20' }

    describe 'Lessons in period' do

      it 'returns client lessons count' do
        expect(subject).to be_valid
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          lessons_count: 2
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
          lessons_count: 2
        )
      end

      it 'returns client lessons amount' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          lessons_amount: yan_lessons.sum(&:price)
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
          lessons_amount: feb_lessons.sum(&:price)
        )
      end
    end

    describe 'All lessons' do

      it 'returns total client lessons count' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          total_lessons_count: 4
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
            total_lessons_count: 2
        )
      end

      it 'returns client total lessons amount' do
        expect(result.first.as_json.symbolize_keys).to include(
            id: first_student.id,
            total_lessons_amount: (yan_lessons + march_lessons).sum(&:price)
          )
        expect(result[1].as_json.symbolize_keys).to include(
            id: second_student.id,
            total_lessons_amount: feb_lessons.sum(&:price)
          )
      end
    end

    describe 'Teachers in period' do
      it 'returns client teachers count' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          teachers_count: 1
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
          teachers_count: 1
        )
      end
    end

    describe 'All Teachers' do
      it 'returns total client teachers count' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          total_teachers_count: 2
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
          total_teachers_count: 1
        )
      end
    end

    describe 'First lesson' do
      it 'returns first client lesson date' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          first_lesson_date: be_within(1.second).of(yan_lessons.first.time_start)
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
          first_lesson_date: be_within(1.second).of(feb_lessons.first.time_start)
        )
      end
    end

    describe 'Last lesson' do
      it 'returns last client lesson date' do
        expect(result.first.as_json.symbolize_keys).to include(
          id: first_student.id,
          last_lesson_date: be_within(1.second).of(march_lessons.last.time_start)
        )
        expect(result[1].as_json.symbolize_keys).to include(
          id: second_student.id,
          last_lesson_date: be_within(1.second).of(feb_lessons.last.time_start)
        )
      end
    end

  end

  describe 'Pagination' do
    let!(:students) { create_list(:student, 10) }
    let!(:lessons) do
      (Date.parse('2017-01-01')..Date.parse('2017-01-10')).map.with_index do |date, i|
        student = students[i]
        Timecop.freeze(date.midday) { create_list(:lesson, 2, :paid, :today, student: student) }
      end
    end

    subject { ClientsReport.run(start_date: '2017-01-01', end_date: '2017-01-10', per_page: 5, page: page) }

    context 'The first page' do
      let(:page) { 1 }

      it 'returns first 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:id)).to eq(students[0..4].map(&:id))
        expect(result.map(&:lessons_count)).to eq(Array.new(5) { 2 })
      end
    end

    context 'The second page' do
      let(:page) { 2 }

      it 'returns second 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:id)).to eq(students[5..9].map(&:id))
        expect(result.map(&:lessons_count)).to eq(Array.new(5) { 2 })
      end
    end
  end

  describe 'Ordering' do
    let(:first_student){ create(:student, last_seen: Time.current.midday) }
    let(:second_student){ create(:student, last_seen: 1.day.ago) }
    let(:third_student){ create(:student, last_seen: 2.day.ago) }

    let!(:first_lesson){ create :lesson, :today, :paid, time_start: 1.day.ago, student: first_student }
    let!(:second_lesson){ create :lesson, :today, :paid, time_start: Time.current.midday, student: second_student }
    let!(:third_lesson){ create :lesson, :today, :paid, time_start: 1.day.since, time_end: 25.hours.since, student: third_student }

    subject { ClientsReport.run(start_date: 2.days.ago.to_date, end_date: 2.days.since.to_date, order: order, direction: direction) }

    context 'First lesson date' do
      let(:order) { 'first_lesson_date' }
      context 'asc' do
        let(:direction) { 'asc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([first_student.id, second_student.id, third_student.id])
        end
      end
      context 'desc' do
        let(:direction) { 'desc' }

        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([third_student.id, second_student.id, first_student.id])
        end
      end
    end

    context 'Last lesson date' do
      let(:order) { 'last_lesson_date' }
      context 'asc' do
        let(:direction) { 'asc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([first_student.id, second_student.id, third_student.id])
        end
      end
      context 'desc' do
        let(:direction) { 'desc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([third_student.id, second_student.id, first_student.id])
        end
      end
    end

    context 'Last seen date' do
      let(:order) { 'last_seen' }
      context 'asc' do
        let(:direction) { 'asc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([third_student.id, second_student.id, first_student.id])
        end
      end
      context 'desc' do
        let(:direction) { 'desc' }
        it 'returns clients in asc order' do
          expect(result.map(&:id)).to eq([first_student.id, second_student.id, third_student.id])
        end
      end
    end

  end
end