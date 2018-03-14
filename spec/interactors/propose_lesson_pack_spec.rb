require 'rails_helper'

RSpec.describe ProposeLessonPack do
  let(:lesson_pack) { create(:lesson_pack, :with_items) }

  context 'Default' do
    subject { ProposeLessonPack.run(lesson_pack: lesson_pack, send_notifications: false) }

    it 'Change status to pending_student' do
      expect{ subject }.to change{ lesson_pack.status }.to('pending_student')
      expect(subject).to be_valid
      expect(LessonPackNotificationsJob).to_not be_queued
    end
  end

  context 'Notifications' do
    subject { ProposeLessonPack.run(lesson_pack: lesson_pack) }

    it 'push notification job' do
      expect(subject).to be_valid
      expect(LessonPackNotificationsJob).to have_queued(:notify_student_about_new_lesson_pack, lesson_pack.id)
    end
  end

end