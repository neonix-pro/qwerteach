require 'rails_helper'

RSpec.describe LessonsReport, type: :report do
  describe 'Monthly' do
    let!(:yan_lessons) do
      Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2) }
    end

    let!(:feb_lessons) do
      Timecop.freeze(Time.parse('2017-02-02')) { create_list(:lesson, 2) }
    end

    let(:result) { subject.result }

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-03-30') }

    it 'returns 2 report entities' do
      expect(subject).to be_valid
      expect(result[0].total_count).to eq(2)
      expect(result[0].period).to eq('2017-01')
      expect(result[1].total_count).to eq(2)
      expect(result[1].period).to eq('2017-02')
      expect(result[2].total_count).to eq(0)
      expect(result[2].period).to eq('2017-03')
    end
  end

  describe 'Daily' do
    let!(:lessons) do
      (Date.parse('2017-01-01')..Date.parse('2017-01-02')).map do |date|
        Timecop.freeze(date.midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-01-03', gradation: :daily) }
    let(:result) { subject.result }

    it 'returns 2 report entities' do
      expect(subject).to be_valid
      expect(result[0].total_count).to eq(2)
      expect(result[0].period).to eq('2017-01-01')
      expect(result[1].total_count).to eq(2)
      expect(result[1].period).to eq('2017-01-02')
      expect(result[2].total_count).to eq(0)
      expect(result[2].period).to eq('2017-01-03')
    end
  end

  describe 'Pagination' do
    let!(:lessons) do
      (Date.parse('2017-01-01')..Date.parse('2017-01-10')).map do |date|
        Timecop.freeze(date.midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-01-10', gradation: :daily, per_page: 5, page: page) }
    let(:result) { subject.result }

    context 'The first page' do
      let(:page) { 1 }

      it 'returns first 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:period)).to eq(%w[2017-01-01 2017-01-02 2017-01-03 2017-01-04 2017-01-05])
        expect(result.map(&:total_count)).to eq(Array.new(5) { 2 })
      end
    end

    context 'The second page' do
      let(:page) { 2 }
      it 'returns second 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:period)).to eq(%w[2017-01-06 2017-01-07 2017-01-08 2017-01-09 2017-01-10])
        expect(result.map(&:total_count)).to eq(Array.new(5) { 2 })
      end
    end
  end

  describe 'Metrics' do

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-01-31') }

    describe 'Created lessons' do
      let!(:created_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :created, price: 10 )}
      end

      let!(:new_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2)}
      end

      it 'returns report entities with created_count' do
        expect(subject).to be_valid
        expect(subject.result.first.total_count).to eq(4)
        expect(subject.result.first.created_count).to eq(2)
      end

      it 'returns report entites with created_amount' do
        expect(subject.result.first.created_amount).to eq(20)
      end
    end

    describe 'Expired lessons' do
      let!(:created_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, status: Lesson.statuses[:expired] )}
      end

      let!(:new_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2)}
      end

      it 'returns report entities with expired_count' do
        expect(subject).to be_valid
        expect(subject.result.first.total_count).to eq(4)
        expect(subject.result.first.created_count).to eq(0)
        expect(subject.result.first.expired_count).to eq(2)
      end
    end

    describe 'Unpaid lessons' do
      let!(:paid_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid)}
      end

      let!(:unpaid_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :created, price: 20)}
      end

      it 'returns report entities with unpaid_count' do
        expect(subject).to be_valid
        expect(subject.result.first.total_count).to eq(4)
        expect(subject.result.first.unpaid_count).to eq(2)
      end

      it 'returns report entities with unpaid amount' do
        expect(subject.result.first.unpaid_amount).to eq(40)
      end
    end

    describe 'Students' do
      let(:student) { create(:student) }
      let!(:lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid)}
      end
      let!(:student_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid, student: student)}
      end
      let!(:old_lessons) do
        Timecop.freeze(Time.parse('2016-12-02')) { create(:lesson, :paid, student: student)}
      end

      it 'returns report entity with students count' do
        expect(subject).to be_valid
        expect(subject.result.first.total_count).to eq(4)
        expect(subject.result.first.students_count).to eq(3)
      end

      it 'returns report entity with new students count' do
        expect(subject.result.first.new_students_count).to eq(2)
      end
    end

    describe 'Teachers' do
      let(:teacher) { create(:teacher) }
      let!(:lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid) }
      end
      let!(:teacher_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid, teacher: teacher) }
      end
      let!(:old_lessons) do
        Timecop.freeze(Time.parse('2016-12-02')) { create(:lesson, :paid, teacher: teacher)}
      end

      it 'returns report entity with teachers count' do
        expect(subject).to be_valid
        expect(subject.result.first.total_count).to eq(4)
        expect(subject.result.first.teachers_count).to eq(3)
      end

      it 'returns report entity with new teachers count' do
        expect(subject.result.first.new_teachers_count).to eq(2)
      end
    end
  end

end