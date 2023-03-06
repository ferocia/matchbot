# frozen_string_literal: true

require 'graphql/batch'

class MatchbotSchema < GraphQL::Schema
  mutation(Types::Mutation)
  query(Types::Query)

  use GraphQL::Batch

  def self.id_from_object(object, _type_definition, _query_ctx)
    GraphQL::Schema::UniqueWithinType.encode(object.class.name, object.id)
  end

  def self.object_from_id(id, _query_ctx)
    type_name, item_id = GraphQL::Schema::UniqueWithinType.decode(id)
    Object.const_get(type_name).find(item_id)
  end
end
