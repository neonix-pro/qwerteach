require 'rails_helper'

RSpec.describe PushMessage do
  let(:message){ 'The story of the cold north always stirs people\'s minds' }
  let(:user){ create :user }
  let(:student){ create :student }
  let(:params){{
      user: user,
      recipient_ids: [user.id, student.id],
      text: message,
      subject: 'subject'
  }}
  let(:conversation){ create :conversation }
  before(:each) do
    allow(PrivatePub).to receive(:publish_to)
    allow(Pusher).to receive(:trigger)
    allow(Pusher).to receive(:notify)
  end

  describe 'Valid message subject' do
    it 'New message' do
      subject = PushMessage.run(params)
      expect(subject.valid?).to be_truthy
      expect(subject.conversation.messages.last.persisted?).to be_truthy
      expect(subject.conversation.messages.last.body).to eq message
    end

    it 'Message to the specified dialog' do
      expect(conversation.messages).to eq []
      subject = PushMessage.run(params.merge({conversation_id: conversation.id, recipient_ids: nil}))
      expect(subject.conversation.id).to eq conversation.id
      expect(subject.conversation.messages.last.body).to eq message
    end
  end

  describe 'Invalid message subject' do
    it 'can not send a message to yourself' do
      subject = PushMessage.run(params.merge({recipient_ids: [user.id, user.id]}))
      expect(subject.valid?).to be_falsey
      expect(subject.errors.keys).to match_array [:to_self]
    end

    it 'the message has no recipient' do
      subject = PushMessage.run(params.merge({recipient_ids: []}))
      expect(subject.valid?).to be_falsey
      expect(subject.errors.keys).to match_array [:recipients]
    end

    it 'can not be sent to a non-existent conversation' do
      subject = PushMessage.run(params.merge({conversation_id: 11223344}))
      expect(subject.valid?).to be_falsey
      expect(subject.errors.keys).to match_array [:conversation]
    end

    it 'the first message should not be short' do
      subject = PushMessage.run(params.merge({text: 'short message'}))
      expect(subject.valid?).to be_falsey
      expect(subject.errors.keys).to match_array [:message]
    end
  end
end




