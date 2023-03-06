# frozen_string_literal: true

class Types::Base::InputObject < GraphQL::Schema::InputObject
  argument_class Types::Base::Argument
end
