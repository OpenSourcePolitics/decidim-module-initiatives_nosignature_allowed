# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:organization) { create(:organization) }
      let(:initiatives_type) { create(:initiatives_type, organization: organization) }
      let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }

      let(:title) { Decidim::Faker::Localized.sentence(5) }
      let(:no_signature) { nil }

      let(:attributes) do
        {
            title: title,
            description: Decidim::Faker::Localized.sentence(25),
            type_id: initiatives_type.id,
            scope_id: scope&.scope&.id,
            signature_type: "offline",
            no_signature: no_signature
        }
      end
      let(:context) do
        {
            current_organization: organization,
            current_component: nil
        }
      end

      let(:state) { "validating" }
      let(:initiative) { create(:initiative, organization: organization, state: state, scoped_type: scope) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when title is missing" do
        let(:title) { nil }

        it { is_expected.to be_invalid }
      end

      context "when no signature allowed is activated" do
        let(:initiatives_type) { create(:initiatives_type, :no_signature_allowed, organization: organization) }
        let(:no_signature) { true }

        it { is_expected.to be_valid }

        context "when no signature allowed is not activated" do
          let(:initiatives_type) { create(:initiatives_type, organization: organization) }

          it { is_expected.to be_invalid }
        end
      end

      describe "#signature_type_updatable?" do
        context "when created" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          let(:state) { "created" }

          it { is_expected.to eq(true) }
        end

        context "when not yet created" do
          subject { described_class.from_params(attributes).with_context(context).signature_type_updatable? }

          let(:state) { nil }

          it { is_expected.to eq(true) }
        end

        context "when any other state" do
          subject { described_class.from_model(initiative).with_context(context).signature_type_updatable? }

          it { is_expected.to eq(false) }
        end
      end

      context "when no scope is present" do
        let(:scope) { nil }

        it { is_expected.to be_valid }
      end
    end
  end
end
