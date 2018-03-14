require 'rails_helper'

RSpec.describe RescheduleLesson do

  let(:lesson) { create(:lesson, :created, time_start: 5.days.since, time_end: 6.days.since) }

  subject { RescheduleLesson.run(user: user, lesson: lesson, new_date: new_date) }

  describe 'Teacher' do
    let(:new_date) { 20.days.since }
    let(:user) { lesson.teacher }

    it 'reschedule lesson' do
      duration = lesson.time_end - lesson.time_start
      expect(subject).to be_valid
      expect(lesson.reload.time_start).to be_within(1.second).of(new_date)
      expect(lesson.time_end).to be_within(1.second).of(new_date + duration)
      expect(lesson.rescheduled).to eq(0)
    end
  end

  describe 'Student' do
    let(:new_date) { 20.days.since }
    let(:user) { lesson.student }

    it 'reschedule lesson' do
      duration = lesson.time_end - lesson.time_start
      expect(subject).to be_valid
      expect(lesson.reload.time_start).to be_within(1.second).of(new_date)
      expect(lesson.time_end).to be_within(1.second).of(new_date + duration)
      expect(lesson.rescheduled).to eq(1)
    end
  end

  describe 'Already rescheduled' do
    let(:new_date) { 20.days.since }
    let(:user) { lesson.student }
    before(:each) { lesson.update(rescheduled: 1) }

    it 'return error due to rescheduling limit' do
      expect(subject).to_not be_valid
    end
  end

  describe 'New date is less than 24 hours from now' do
    let(:new_date) { 10.hours.since }
    let(:user) { lesson.student }

    it 'return error due to incorrect new date' do
      expect(subject).to_not be_valid
    end
  end

  describe 'Less 24 hours to begin' do
    let(:lesson) { create(:lesson, :created, time_start: 10.hours.since) }
    let(:user) { lesson.student }
    let(:new_date) { 2.days.since }

    it 'return error due to time start less 24 hours' do
      expect(subject).to_not be_valid
    end
  end
end