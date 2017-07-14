require 'rails_helper'

RSpec.describe SendMessage do
  let(:message) { 'The story of the cold north always stirs people\'s minds' }
  let(:user) { create :teacher }
  let(:student) { create :student }
  let(:params) do
    {
      user: user,
      recipient_ids: [student.id],
      body: message,
      subject: FFaker::Lorem.phrase
    }
  end

  context 'Two recipients' do

    let(:conversation){ user.send_message(student, FFaker::Lorem.paragraph, FFaker::Lorem.phrase ).conversation }

    describe 'with valid params' do

      before(:each) do
        expect(PrivatePub).to receive(:publish_to).exactly(2).times
        expect(Pusher).to receive(:trigger).exactly(1).times
        expect(Pusher).to receive(:notify).exactly(1).times
      end

      it 'creates new conversation' do
        subject = SendMessage.run(params)
        expect(subject.valid?).to be_truthy

        conversation = Mailboxer::Conversation.between(user, student).first
        expect(conversation.original_message.subject).to eq(params[:subject])
        expect(conversation.last_message.body).to eq(params[:body])
        expect(user.mailbox.conversations.last).to eq(conversation)
        expect(student.mailbox.conversations.last).to eq(conversation)
      end

      it 'sends message to existed conversation' do
        expect(conversation.messages.size).to eq 1
        subject = SendMessage.run(params.merge({conversation_id: conversation.id}))
        expect(subject.valid?).to be_truthy

        expect(conversation.reload.messages.size).to eq 2
        expect(conversation.last_message.body).to eq(params[:body])
        expect(user.mailbox.conversations.last).to eq(conversation)
        expect(student.mailbox.conversations.last).to eq(conversation)
      end
    end

    describe 'Invalid message subject' do
      it 'can not send a message to yourself' do
        subject = SendMessage.run(params.merge({recipient_ids: [user.id]}))
        expect(subject.valid?).to be_falsey
        expect(subject.errors.keys).to match_array [:to_self]
      end

      it 'the message has no recipient' do
        subject = SendMessage.run(params.merge({recipient_ids: []}))
        expect(subject.valid?).to be_falsey
        expect(subject.errors.keys).to include :recipient_ids
      end

      it 'can not be sent to a non-existent conversation' do
        expect{ SendMessage.run params.merge(conversation_id: 11223344) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'the first message should not be short' do
        subject = SendMessage.run params.merge(body: 'short message')
        expect(subject.valid?).to be_falsey
        expect(subject.errors.keys).to match_array [:body]
      end
    end
  end
end




