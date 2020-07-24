# frozen_string_literal: true

require "spec_helper"

describe "User prints the initiative", type: :system do
  include_context "when admins initiative"

  def submit_and_validate
    find("*[type=submit]").click

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end
  end

  context "when initiative update" do
    context "and user is author" do
      before do
        switch_to_host(organization.host)
        login_as author, scope: :user
        visit decidim_admin_initiatives.initiatives_path
      end

      context "when initiative is in created state" do
        before do
          initiative.created!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_initiative" do
            select translated(other_initiatives_type.title), from: "initiative_type_id"
            select translated(other_initiatives_type_scope), from: "initiative_decidim_scope_id"
            select "In-person", from: "initiative_signature_type"
          end
          submit_and_validate
        end
      end

      context "when initiative is in validating state" do
        before do
          initiative.validating!
        end

        it "update of type, scope and signature type are disabled" do
          page.find(".action-icon--edit").click

          within ".edit_initiative" do
            expect(page).to have_css("#initiative_type_id[disabled]")
            expect(page).to have_css("#initiative_decidim_scope_id[disabled]")
            expect(page).to have_css("#initiative_signature_type[disabled]")
          end
          expect(page).to have_no_css("*[type=submit]")
        end
      end
    end

    context "and user is admin" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_admin_initiatives.initiatives_path
      end

      it "Updates published initiative data" do
        page.find(".action-icon--edit").click
        within ".edit_initiative" do
          fill_in :initiative_hashtag, with: "#hashtag"
        end
        submit_and_validate
      end

      context "when initiative is in created state" do
        before do
          initiative.created!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_initiative" do
            select translated(other_initiatives_type.title), from: "initiative_type_id"
            select translated(other_initiatives_type_scope), from: "initiative_decidim_scope_id"
            select "In-person", from: "initiative_signature_type"
          end
          submit_and_validate
        end
      end

      context "when initiative is in validating state" do
        before do
          initiative.validating!
        end

        it "updates type, scope and signature type" do
          page.find(".action-icon--edit").click
          within ".edit_initiative" do
            select translated(other_initiatives_type.title), from: "initiative_type_id"
            select translated(other_initiatives_type_scope), from: "initiative_decidim_scope_id"
            select "In-person", from: "initiative_signature_type"
          end
          submit_and_validate
        end
      end

      context "when initiative is in accepted state" do
        before do
          initiative.accepted!
        end

        it "update of type, scope and signature type are disabled" do
          page.find(".action-icon--edit").click

          within ".edit_initiative" do
            expect(page).to have_css("#initiative_type_id[disabled]")
            expect(page).to have_css("#initiative_decidim_scope_id[disabled]")
            expect(page).to have_css("#initiative_signature_type[disabled]")
          end
        end
      end
    end

    context "when no signature allowed" do
      let!(:initiative) { create(:initiative, organization: organization, author: author, scoped_type: scoped_type) }
      let(:scoped_type) { create(:initiatives_type_scope, type: initiatives_type) }
      let(:initiatives_type) { create(:initiatives_type, :no_signature_allowed, organization: organization) }

      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_admin_initiatives.initiatives_path
      end

      it "displays checkbox" do
        page.find(".action-icon--edit").click

        within ".edit_initiative" do
          expect(page).to have_unchecked_field("No signature")
        end
      end

      context "when custom signature end date enabled and no signature is selected" do
        let!(:initiative) { create(:initiative, :created, organization: organization, author: author, scoped_type: scoped_type) }
        let(:initiatives_type) { create(:initiatives_type, :no_signature_allowed, :custom_signature_end_date_enabled, organization: organization) }

        before do
          page.find(".action-icon--edit").click
        end

        it "hides the signature end date" do
          check("No signature")

          expect(page).not_to have_content("End of signature collection period")
        end
      end

      context "when custom signature end date enabled and no signature is deselected" do
        let!(:initiative) { create(:initiative, :created, :no_signature, organization: organization, author: author, scoped_type: scoped_type) }
        let(:initiatives_type) { create(:initiatives_type, :no_signature_allowed, :custom_signature_end_date_enabled, organization: organization) }

        before do
          page.find(".action-icon--edit").click
        end

        it "shows the signature end date" do
          uncheck("No signature")

          expect(page).to have_content("End of signature collection period")
        end
      end
    end
  end
end
