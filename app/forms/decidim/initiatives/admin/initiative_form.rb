# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A form object used to show the initiative data in the administration
      # panel.
      class InitiativeForm < Form
        include TranslatableAttributes

        mimic :initiative

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :type_id, Integer
        attribute :decidim_scope_id, Integer
        attribute :signature_type, String
        attribute :signature_start_date, Decidim::Attributes::LocalizedDate
        attribute :signature_end_date, Decidim::Attributes::LocalizedDate
        attribute :hashtag, String
        attribute :offline_votes, Integer
        attribute :state, String
        attribute :no_signature, Boolean

        validates :title, :description, presence: true
        validates :signature_type, presence: true, if: :signature_type_updatable?
        validates :signature_start_date, presence: true, if: ->(form) { form.context.initiative.published? }
        validates :signature_end_date, presence: true, if: ->(form) { form.context.initiative.published? }
        validates :signature_end_date, date: { after: :signature_start_date }, if: lambda { |form|
          form.signature_start_date.present? && form.signature_end_date.present?
        }
        validates :signature_end_date, date: { after: Date.current }, if: lambda { |form|
          form.signature_start_date.blank? && form.signature_end_date.present?
        }

        validates :offline_votes,
                  numericality: {
                    only_integer: true,
                    greater_than: 0
                  }, allow_blank: true

        validate :check_no_signature

        def map_model(model)
          self.type_id = model.type.id
          self.decidim_scope_id = model.scope&.id
        end

        def check_no_signature
          return true if no_signature.blank?

          errors.add(:no_signature, I18n.t("activemodel.errors.models.initiatives.no_signature_allowed")) unless type.no_signature_allowed?
        end

        def signature_type_updatable?
          @signature_type_updatable ||= begin
                                          state ||= context.initiative.state
                                          state == "validating" && context.current_user.admin? || state == "created"
                                        end
        end

        def state_updatable?
          false
        end

        def scoped_type_id
          return unless type && decidim_scope_id

          type.scopes.find_by!(decidim_scopes_id: decidim_scope_id).id
        end

        private

        def type
          @type ||= type_id ? Decidim::InitiativesType.find(type_id) : context.initiative.type
        end
      end
    end
  end
end
