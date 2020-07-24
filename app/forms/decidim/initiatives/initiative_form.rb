# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the data for a new initiative.
    class InitiativeForm < Form
      include TranslatableAttributes

      mimic :initiative

      attribute :title, String
      attribute :description, String
      attribute :type_id, Integer
      attribute :scope_id, Integer
      attribute :decidim_user_group_id, Integer
      attribute :signature_type, String
      attribute :signature_end_date, Date
      attribute :state, String
      attribute :no_signature, Boolean

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :signature_type, presence: true
      validates :type_id, presence: true
      validate :scope_exists
      validates :signature_end_date, date: { after: Date.current }, if: lambda { |form|
        type.custom_signature_end_date_enabled? && form.signature_end_date.present?
      }
      validate :check_no_signature

      def map_model(model)
        self.type_id = model.type.id
        self.scope_id = model.scope&.id
      end

      def check_no_signature
        return true if no_signature.blank?

        errors.add(:no_signature, I18n.t("activemodel.errors.models.initiatives.no_signature_allowed")) unless type.no_signature_allowed?
      end

      def signature_type_updatable?
        state == "created" || state.nil?
      end

      def scope_id
        super.presence
      end

      private

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless InitiativesTypeScope.where(decidim_initiatives_types_id: type_id, decidim_scopes_id: scope_id).exists?
      end

      def type
        @type ||= Decidim::InitiativesType.find(type_id)
      end
    end
  end
end
