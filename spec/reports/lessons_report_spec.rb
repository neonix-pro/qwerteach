require 'rails_helper'

RSpec.describe LessonsReport, type: :report do
  let(:result) { subject.result }

  describe 'Monthly' do
    let!(:yan_lessons) do
      Timecop.freeze(Time.zone.parse('2017-01-02').midday) { create_list(:lesson, 2) }
    end

    let!(:feb_lessons) do
      Timecop.freeze(Time.zone.parse('2017-02-02').midday) { create_list(:lesson, 2) }
    end

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-03-30') }

    it 'returns 2 report entities' do
      expect(subject).to be_valid
      expect(result[0].total_count).to eq(2)
      expect(result[0].period).to be_within(1.second).of Time.zone.parse('2017-01-01')
      expect(result[1].total_count).to eq(2)
      expect(result[1].period).to be_within(1.second).of Time.zone.parse('2017-02-01')
      expect(result[2].total_count).to eq(0)
      expect(result[2].period).to be_within(1.second).of Time.zone.parse('2017-03-01')
    end
  end

  describe 'Daily' do
    let!(:lessons) do
      (Date.parse('2017-01-01').to_date..Date.parse('2017-01-02')).map do |date|
        Timecop.freeze(date.midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-01-03', gradation: :daily) }

    it 'returns report entities for 3 days' do
      expect(subject).to be_valid
      expect(result[0].total_count).to eq(2)
      expect(result[0].period).to be_within(1.second).of Time.zone.parse('2017-01-01')
      expect(result[1].total_count).to eq(2)
      expect(result[1].period).to be_within(1.second).of Time.zone.parse('2017-01-02')
      expect(result[2].total_count).to eq(0)
      expect(result[2].period).to be_within(1.second).of Time.zone.parse('2017-01-03')
    end
  end

  describe 'Weekly' do
    let(:dates) { %w[2017-11-06 2017-11-14 2017-11-28] }
    let!(:lessons) do
      dates.map do |date|
        Timecop.freeze(Date.parse(date).midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { LessonsReport.run(start_date: '2017-11-06', end_date: '2017-11-22', gradation: :weekly) }

    it 'returns report entities for 3 weeks' do
      expect(subject).to be_valid
      expect(result[0].total_count).to eq(2)
      expect(result[0].period).to be_within(1.second).of Time.zone.parse('2017-11-06')
      expect(result[1].total_count).to eq(2)
      expect(result[1].period).to be_within(1.second).of Time.zone.parse('2017-11-13')
      expect(result[2].total_count).to eq(0)
      expect(result[2].period).to be_within(1.second).of Time.zone.parse('2017-11-20')
    end
  end

  describe 'Quarterly' do
    let(:dates) { %w[2017-01-06 2017-04-06 2017-10-06] }
    let!(:lessons) do
      dates.map do |date|
        Timecop.freeze(Date.parse(date).midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-09-30', gradation: :quarterly) }

    it 'returns report entities for 3 quarters' do
      expect(subject).to be_valid
      expect(result[0].total_count).to eq(2)
      expect(result[0].period).to be_within(1.second).of Time.zone.parse('2017-01-01')
      expect(result[1].total_count).to eq(2)
      expect(result[1].period).to be_within(1.second).of Time.zone.parse('2017-04-01')
      expect(result[2].total_count).to eq(0)
      expect(result[2].period).to be_within(1.second).of Time.zone.parse('2017-07-01')
    end
  end

  describe 'Pagination' do
    let!(:lessons) do
      (Date.parse('2017-01-01')..Date.parse('2017-01-10')).map do |date|
        Timecop.freeze(date.midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { LessonsReport.run(start_date: '2017-01-01', end_date: '2017-01-10', gradation: :daily, per_page: 5, page: page) }

    context 'The first page' do
      let(:page) { 1 }

      it 'returns first 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:period)).to eq(%w[2017-01-01 2017-01-02 2017-01-03 2017-01-04 2017-01-05].map { |d| Time.zone.parse(d) })
        expect(result.map(&:total_count)).to eq(Array.new(5) { 2 })
      end
    end

    context 'The second page' do
      let(:page) { 2 }
      it 'returns second 5 entities' do
        expect(subject).to be_valid
        expect(result.map(&:period)).to eq(%w[2017-01-06 2017-01-07 2017-01-08 2017-01-09 2017-01-10].map { |d| Time.zone.parse(d) })
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