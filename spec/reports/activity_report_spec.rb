require 'rails_helper'

RSpec.describe ActivityReport, type: :report do

  let(:result) { subject.result }

  context 'Few months' do
    let!(:yan_lessons) do
      Timecop.freeze(Time.parse('2017-01-02').midday) { create_list(:lesson, 2, :paid, :today) }
    end

    let!(:feb_lessons) do
      Timecop.freeze(Time.parse('2017-02-02').midday) { create_list(:lesson, 2, :paid, :today) }
    end

    subject { ActivityReport.run(start_date: '2017-01-01', end_date: '2017-03-30') }

    it 'returns 2 report entities' do
      expect(subject).to be_valid
      expect(result.size).to eq(3)
      expect(result[2].lessons_count).to eq(2)
      expect(result[2].period.strftime('%Y-%m-%d')).to eq('2017-01-01')
      expect(result[1].lessons_count).to eq(2)
      expect(result[1].period.strftime('%Y-%m-%d')).to eq('2017-02-01')
      expect(result[0].lessons_count).to eq(0)
      expect(result[0].period.strftime('%Y-%m-%d')).to eq('2017-03-01')
    end
  end

  describe 'Pagination' do
    let!(:lessons) do
      Array.new(10) do |i|
        Timecop.freeze(Date.parse("2017-#{(i+1).to_s.rjust(2,'0')}-01").midday) { create_list(:lesson, 2, :paid, :today) }
      end
    end

    subject { ActivityReport.run(start_date: '2017-01-01', end_date: '2017-10-31', per_page: 5, page: page) }

    context 'The first page' do
      let(:page) { 1 }

      it 'returns first 5 entities' do
        expect(subject).to be_valid
        expect(result.map { |entity| entity.period.strftime('%Y-%m-%d') })
          .to eq(%w[2017-05-01 2017-04-01 2017-03-01 2017-02-01 2017-01-01])
        expect(result.map(&:lessons_count)).to eq(Array.new(5) { 2 })
      end
    end

    context 'The second page' do
      let(:page) { 2 }
      it 'returns second 5 entities' do
        expect(subject).to be_valid
        expect(result.map { |entity| entity.period.strftime('%Y-%m-%d') })
          .to eq(%w[2017-10-01 2017-09-01 2017-08-01 2017-07-01 2017-06-01])
        expect(result.map(&:lessons_count)).to eq(Array.new(5) { 2 })
      end
    end
  end

  describe 'Metrics' do
    subject { ActivityReport.run(start_date: '2017-01-01', end_date: '2017-01-31') }

    it('has one entity'){ expect(result.size).to eq(1) }

    describe 'Created lessons' do
      let!(:created_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid, price: 10 ) }
      end

      let!(:new_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, price: 40) }
      end

      it 'returns report entities with created_count' do
        expect(subject.result.first.lessons_count).to eq(2)
      end

      it 'returns report entites with created_amount' do
        expect(subject.result.first.lessons_amount).to eq(20)
      end
    end

    describe 'Students' do
      let(:first_student){ create(:student) }
      let(:second_student){ create(:student) }
      let!(:created_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid, student: first_student ) }
        Timecop.freeze(Time.parse('2017-01-03')) { create_list(:lesson, 2, :paid, student: second_student ) }
      end

      let!(:new_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, price: 40) }
      end

      let!(:old_lessons) do
        Timecop.freeze(Time.parse('2016-10-10')) { create_list(:lesson, 2, :created, student: first_student) }
        Timecop.freeze(Time.parse('2016-10-20')) { create_list(:lesson, 2, :created) }
      end

      it 'returns report entities with students_count' do
        expect(result.first.students_count).to eq(2)
      end

      it 'returns report entites with new_students_count' do
        expect(result.first.new_students_count).to eq(1)
      end
    end

    describe 'Teachers' do
      let(:first_teacher){ create(:teacher) }
      let(:second_teacher){ create(:teacher) }
      let!(:created_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2, :paid, teacher: first_teacher ) }
        Timecop.freeze(Time.parse('2017-01-03')) { create_list(:lesson, 2, :paid, teacher: second_teacher ) }
      end

      let!(:new_lessons) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:lesson, 2) }
      end

      let!(:old_lessons) do
        Timecop.freeze(Time.parse('2016-10-10')) { create_list(:lesson, 2, :created, teacher: first_teacher) }
        Timecop.freeze(Time.parse('2016-10-20')) { create_list(:lesson, 2, :created) }
      end

      it 'returns report entities with teachers_count' do
        expect(result.first.teachers_count).to eq(2)
      end

      it 'returns report entites with new_teachers_count' do
        expect(result.first.new_teachers_count).to eq(1)
      end
    end

    describe 'Disputes' do
      let!(:disputes) do
        Timecop.freeze(Time.parse('2017-01-02')) { create_list(:dispute, 2) }
      end

      let!(:old_disputes) do
        Timecop.freeze(Time.parse('2016-10-20')) { create_list(:dispute, 2) }
      end

      it 'returns report entity with correct disputes_count' do
        expect(result.first.disputes_count).to eq(2)
      end
    end
  end


end