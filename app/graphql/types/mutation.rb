# frozen_string_literal: true

class Types::Mutation < Types::Base::Object
  field :createMatch, mutation: Mutations::CreateMatch
end
