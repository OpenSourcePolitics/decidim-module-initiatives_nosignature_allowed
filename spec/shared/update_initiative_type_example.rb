# frozen_string_literal: true

shared_examples "update an initiative type" do
  let(:organization) { create(:organization) }
  let(:initiative_type) { create(:initiatives_type, :online_signature_enabled, :undo_online_signatures_enabled, :custom_signature_end_date_disabled, organization: organization) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: initiative_type.organization,
      current_component: nil
    )
  end
  let(:no_signature_allowed) { nil }

  describe "call" do
    let(:form_params) do
      {
        title: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.sentence(25),
        signature_type: "offline",
        undo_online_signatures_enabled: false,
        custom_signature_end_date_enabled: true,
        promoting_committee_enabled: true,
        minimum_committee_members: 7,
        banner_image: Decidim::Dev.test_file("city2.jpeg", "image/jpeg"),
        collect_user_extra_fields: true,
        extra_fields_legal_information: Decidim::Faker::Localized.sentence(25),
        document_number_authorization_handler: "",
        no_signature_allowed: no_signature_allowed
      }
    end

    let(:command) { described_class.new(initiative_type, form) }

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update an initiative type" do
        command.call
        expect(initiative_type.title).not_to eq(form_params[:title])
        expect(initiative_type.description).not_to eq(form_params[:description])
        expect(initiative_type.signature_type).not_to eq(form_params[:signature_type])
        expect(initiative_type.undo_online_signatures_enabled).not_to eq(form_params[:undo_online_signatures_enabled])
        expect(initiative_type.custom_signature_end_date_enabled).not_to eq(form_params[:custom_signature_end_date_enabled])
        expect(initiative_type.minimum_committee_members).not_to eq(form_params[:minimum_committee_members])
      end
    end

    describe "when the form is valid" do
      let(:scope) { create(:initiatives_type_scope, type: initiative_type) }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      context "when no signature allowed" do
        let(:no_signature_allowed) { true }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end
      end

      it "updates the initiative type" do
        command.call

        expect(initiative_type.title).to eq(form_params[:title])
        expect(initiative_type.description).to eq(form_params[:description])
        expect(initiative_type.signature_type).to eq(form_params[:signature_type])
        expect(initiative_type.undo_online_signatures_enabled).to eq(form_params[:undo_online_signatures_enabled])
        expect(initiative_type.custom_signature_end_date_enabled).to eq(form_params[:custom_signature_end_date_enabled])
        expect(initiative_type.minimum_committee_members).to eq(form_params[:minimum_committee_members])
      end

      it "propagates signature type to created initiatives" do
        initiative = create(:initiative, :created, organization: organization, scoped_type: scope, signature_type: "online")

        command.call
        initiative.reload

        expect(initiative.signature_type).to eq("offline")
      end

      it "doesn't propagate signature type to non-created initiatives" do
        initiative = create(:initiative, :published, organization: organization, scoped_type: scope, signature_type: "online")

        command.call
        initiative.reload

        expect(initiative.signature_type).to eq("online")
      end
    end
  end
end
