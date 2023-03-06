# frozen_string_literal: true

class Types::Base::Field < GraphQL::Schema::Field
  argument_class Types::Base::Argument

  def resolve_field(obj, args, ctx)
    resolve(obj, args, ctx)
  end
end
