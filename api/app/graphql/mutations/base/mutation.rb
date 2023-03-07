# frozen_string_literal: true

class Mutations::Base::Mutation < GraphQL::Schema::Mutation
  # # Add your custom classes if you have them:
  # # This is used for generating payload types
  # object_class Types::Base::Object
  # # This is used for return fields on the mutation's payload
  # field_class Types::Base::Field
  # # This is used for generating the `input: { ... }` object type
  # input_object_class Types::Base::InputObject
end
