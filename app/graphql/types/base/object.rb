# frozen_string_literal: true

class Types::Base::Object < GraphQL::Schema::Object
  field_class Types::Base::Field
end
