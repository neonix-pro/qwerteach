require 'rails_helper'

feature "payment" do

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


    scenario 'Apply the `all` filter, I see all the disputes' do
      page.find('a.button.all').click
      within('table.collection-data//tbody') do
        expect(page).to have_link('Modifier', href: edit_admin_dispute_path(@dispute_started))
        expect(page).to have_link('Modifier', href: edit_admin_dispute_path(@dispute_finished))
      end
    end

    scenario 'Apply the `started` filter, I see all the disputes' do
      page.find('a.button.started').click
      within('table.collection-data//tbody') do
        expect(page).to have_link('Modifier', href: edit_admin_dispute_path(@dispute_started))
        expect(page).to have_no_link('Modifier', href: edit_admin_dispute_path(@dispute_finished))
      end
    end

    scenario 'Apply the `started` filter, I see all the disputes' do
      page.find('a.button.finished').click
      within('table.collection-data//tbody') do
        expect(page).to have_no_link('Modifier', href: edit_admin_dispute_path(@dispute_started))
        expect(page).to have_link('Modifier', href: edit_admin_dispute_path(@dispute_finished))
      end
    end
  end

  describe 'message' do
    before :each do
      allow(PrivatePub).to receive(:publish_to)
      allow(Pusher).to receive(:trigger)
      allow(Pusher).to receive(:notify)
      login_admin
      visit admin_dispute_path(dispute)
    end


    scenario 'to common conversation' do
      message = 'for common conversation'
      within('#common.tab-pane//form') do
        fill_in 'body', with: message
        find('input[type=submit]').click
      end
      expect(page.find('#common.tab-pane')).to have_content(message)
    end

    scenario 'to student conversation' do
      message = 'for student conversation'
      within('#student.tab-pane//form') do
        fill_in 'body', with: message
        find('input[type=submit]').click
      end
      expect(page.find('#common.tab-pane')).to have_no_content(message)
      expect(page.find('#student.tab-pane')).to have_content(message)
      expect(page.find('#teacher.tab-pane')).to have_no_content(message)
    end

    scenario 'to teacher conversation' do
      message = 'for teacher conversation'
      within('#teacher.tab-pane//form') do
        fill_in 'body', with: message
        find('input[type=submit]').click
      end
      expect(page.find('#common.tab-pane')).to have_no_content(message)
      expect(page.find('#student.tab-pane')).to have_no_content(message)
      expect(page.find('#teacher.tab-pane')).to have_content(message)
    end
  end

  describe 'resolve disput' do
    before :each do
      login_admin
      visit admin_dispute_path(dispute)
    end


    scenario 'resolve disput, moves all money to the teacher' do
      expect(ResolveDispute).to receive(:run)
        .with(dispute: dispute, amount: dispute.lesson.price)
        .and_return(OpenStruct.new('valid?': true))
      page.find('a.button.to_teacher').click
      expect(dispute.valid?).to be_truthy
    end

    scenario 'resolve disput, moves all money to the student' do
      expect(RefundLesson).to receive(:run)
        .with(user: dispute.user, lesson: dispute.lesson)
        .and_return(OpenStruct.new('valid?': true))
      page.find('a.button.to_student').click
      expect(dispute.valid?).to be_truthy
    end

    scenario 'moves a part of money to the teacher' do
      expect(ResolveDispute).to receive(:run)
        .with(dispute: dispute, amount: '20')
        .and_return(OpenStruct.new('valid?': true))
      within('#divide_money.modal//form') do
        fill_in 'price', with: 20
        find('input[type=submit]').click
      end
      expect(dispute.valid?).to be_truthy
    end
  end





end


