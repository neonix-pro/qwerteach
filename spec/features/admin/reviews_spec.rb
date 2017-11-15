require 'rails_helper'

feature Admin::ReviewsController do

  describe 'Index' do
    before :each do
      sign_in_as_admin
    end

    context 'No filters' do
      let!(:reviews) { create_list(:review, 2) }

      scenario 'When I visit reviews page I see reviews' do
        visit admin_reviews_path
        reviews.each do |review|
          expect(page).to have_content(review.sender.name)
          expect(page).to have_content(review.subject.name)
          expect(page).to have_content(review.note)
        end
      end

    end

    context 'Filter by sender' do
      let(:sender) { create(:student) }
      let!(:review) { create(:review, sender: sender) }
      let(:unsuitable_reviews) { create_list(:review, 3) }

      scenario 'When I visit reviews page and chose a sender I see review with it' do
        visit admin_reviews_path
        within '.form-filters' do
          select sender.name, from: "q[sender_id_eq]"
          find('input[type=submit]').click
        end
        expect(page).to have_content(review.sender.name)
        unsuitable_reviews.each do |review|
          expect(page).to_not have_content(review.sender.name)
          expect(page).to_not have_content(review.subject.name)
        end
      end
    end

    context 'Filter by subject' do
      let(:receiver) { create(:teacher) }
      let!(:review) { create(:review, subject: receiver) }
      let(:unsuitable_reviews) { create_list(:review, 3) }

      scenario 'When I visit reviews page and chose a sender I see review with it' do
        visit admin_reviews_path
        within '.form-filters' do
          select receiver.name, from: "q[subject_id_eq]"
          find('input[type=submit]').click
        end
        expect(page).to have_content(review.subject.name)
        unsuitable_reviews.each do |review|
          expect(page).to_not have_content(review.sender.name)
          expect(page).to_not have_content(review.subject.name)
        end
      end
    end

  end

end