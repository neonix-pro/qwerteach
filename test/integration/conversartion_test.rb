require 'test_helper'

class ConversartionTest < ActionDispatch::IntegrationTest
  test "start new conversation" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    get new_message_path
    assert_difference 'Mailboxer::Conversation.count' do
      post messages_path, 'message[subject]' => 'chat', 'message[body]' => 'prout', 'recipients' => [User.find(2)]
    end
    assert_equal 1, Mailboxer::Conversation.first.messages.count
    assert_equal 302, status
    assert_redirected_to conversation_path(Mailboxer::Conversation.first)
  end
  test "start become reply conversation" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    get new_message_path
    post messages_path, 'message[subject]' => 'chat', 'message[body]' => 'prout', 'recipients' => [User.find(2)]
    get new_message_path
    assert_difference 'Mailboxer::Message.count' do
      post messages_path, 'message[subject]' => 'chat', 'message[body]' => 'prout', 'recipients' => [User.find(2)]
    end
    assert_equal 2, Mailboxer::Conversation.first.messages.count
    assert_equal 302, status
    assert_redirected_to conversation_path(Mailboxer::Conversation.first)
  end

  test "reply to conv" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    get new_message_path
    post messages_path, 'message[subject]' => 'chat', 'message[body]' => 'prout', 'recipients' => [User.find(2)]
    get new_message_path
    assert_difference 'Mailboxer::Message.count' do
      post reply_conversation_path(Mailboxer::Conversation.first), 'body' => 'prout'
    end
    assert_equal 2, Mailboxer::Conversation.first.messages.count
    assert_equal 302, status
    assert_redirected_to conversation_path(Mailboxer::Conversation.first)
  end
  test "reply to conv other user" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    get new_message_path
    post messages_path, 'message[subject]' => 'chat', 'message[body]' => 'prout', 'recipients' => [User.find(2)]
    destroy_user_session_path
    post user_session_path, 'user[email]' => 'm@m.m', 'user[password]' => 'kaltrina'
    get new_message_path
    assert_difference 'Mailboxer::Message.count' do
      post reply_conversation_path(Mailboxer::Conversation.first), 'body' => 'caca'
    end
    assert_equal 2, Mailboxer::Conversation.first.messages.count
    assert_equal 302, status
    assert_redirected_to conversation_path(Mailboxer::Conversation.first)
  end

  test "email sent" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    get new_message_path
    post messages_path, 'message[subject]' => 'chat', 'message[body]' => 'prout', 'recipients' => [User.find(4)]
    assert_equal 1, Mailboxer::Conversation.first.messages.count
    assert_equal 0, ActionMailer::Base.deliveries.count
    assert_equal 302, status
    assert_redirected_to conversation_path(Mailboxer::Conversation.first)
    @message = Mailboxer::Conversation.last.messages.last
    @message.created_at = DateTime.now - 6.minutes
    @message.save
    destroy_user_session_path
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      CustomMessageMailer.email_sender_prout(User.find(4), Mailboxer::Conversation.first.messages.count.to_s).deliver_now
      sleep 1
    end
  end
end
