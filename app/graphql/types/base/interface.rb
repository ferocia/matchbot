# frozen_string_literal: true

module Types::Base::Interface
  include GraphQL::Schema::Interface

  field_class Types::Base::Field
end
