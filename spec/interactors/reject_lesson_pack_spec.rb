require 'rails_helper'

RSpec.describe RejectLessonPack do
  let(:lesson_pack) { create(:lesson_pack, :with_items) }

  describe 'Default' do
    subject { RejectLessonPack.run(lesson_pack: lesson_pack, send_notification: false) }

    it 'change status to approved' do
      expect{ subject }.to change { lesson_pack.status }.to('declined')
    end
  end

  describe 'Notifications' do
    subject { RejectLessonPack.run(lesson_pack: lesson_pack) }

    it 'send notification to teacher' do
      expect(subject).to be_valid
      expect(LessonPackNotificationsJob).to have_queued(:notify_teacher_about_rejected_lesson_pack, lesson_pack.id)
    end
  end

end