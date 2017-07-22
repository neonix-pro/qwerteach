require 'rails_helper'

feature 'admin disputes controller' do

  let(:student){ create(:student, email: FFaker::Internet.email) }
  let(:admin){ create(:admin, email: FFaker::Internet.email) }
  let(:dispute){ create(:dispute, user: student) }

  def login_admin
    visit new_user_session_path
    within('.sign_in_page//form') do
      fill_in 'user_email', with: admin.email
      fill_in 'user_password', with: admin.password
      find('input[type=submit]').click
    end
  end

  describe 'index' do
    before :each do
      @dispute_started = create(:dispute, status: 0)
      @dispute_finished = create(:dispute, status: 1)
      login_admin
      visit admin_disputes_path
    end


    scenario 'I see all the disputes' do
      page.find('a.btn.all').click
      expect(page).to have_link(href: admin_dispute_path(@dispute_started))
      expect(page).to have_link(href: admin_dispute_path(@dispute_finished))
    end

    scenario 'I see only started disputes' do
      page.find('a.btn.started').click
      expect(page).to have_link(href: admin_dispute_path(@dispute_started))
      expect(page).to have_no_link(href: admin_dispute_path(@dispute_finished))
    end

    scenario 'I see only resolved disputes' do
      page.find('a.btn.finished').click
      expect(page).to have_no_link(href: admin_dispute_path(@dispute_started))
      expect(page).to have_link(href: admin_dispute_path(@dispute_finished))
    end
  end

  describe 'message' do
    let(:message){ 'The story of the cold north always stirs people\'s minds' }
    before :each do
      login_admin
      visit admin_dispute_path(dispute)
    end


    scenario 'Admin can send a message to common conversation' do
      within('#conversation-0.tab-pane//form') do
        fill_in 'message[body]', with: message
        find('input[type=submit]').click
      end
      expect(page.find('#conversation-0.tab-pane')).to have_content(message)
      expect(page.find('#conversation-1.tab-pane')).to have_no_content(message)
      expect(page.find('#conversation-2.tab-pane')).to have_no_content(message)
    end

    scenario 'to student conversation' do
      within('#conversation-1.tab-pane//form') do
        fill_in 'message[body]', with: message
        find('input[type=submit]').click
      end
      expect(page.find('#conversation-0.tab-pane')).to have_no_content(message)
      expect(page.find('#conversation-1.tab-pane')).to have_content(message)
      expect(page.find('#conversation-2.tab-pane')).to have_no_content(message)
    end

    scenario 'to teacher conversation' do
      within('#conversation-2.tab-pane//form') do
        fill_in 'message[body]', with: message
        find('input[type=submit]').click
      end
      expect(page.find('#conversation-0.tab-pane')).to have_no_content(message)
      expect(page.find('#conversation-1.tab-pane')).to have_no_content(message)
      expect(page.find('#conversation-2.tab-pane')).to have_content(message)
    end

    scenario 'I can not see input in teach and student conversation' do
      expect(page).to_not have_selector('#conversation-4.tab-pane//form')
    end

  end

  describe 'resolve disput' do
    before :each do
      login_admin
      visit admin_dispute_path(dispute)
    end


    scenario 'moves all money to the teacher' do
      expect(ResolveDispute).to receive(:run)
        .with(dispute: dispute, amount: dispute.lesson.price.to_s)
        .and_return(OpenStruct.new('valid?': true))
      page.find('a.btn.to_teacher').click
    end

    scenario 'moves all money to the student' do
      expect(RefundLesson).to receive(:run)
        .with(user: dispute.user, lesson: dispute.lesson)
        .and_return(OpenStruct.new('valid?': true))
      page.find('a.btn.to_student').click
    end

    scenario 'moves a part of money to the teacher' do
      expect(ResolveDispute).to receive(:run)
        .with(dispute: dispute, amount: '20')
        .and_return(OpenStruct.new('valid?': true))
      within('#divide_money.modal//form') do
        fill_in 'amount', with: 20
        find('input[type=submit]').click
      end
    end
  end
end