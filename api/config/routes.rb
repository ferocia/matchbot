# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'

  post 'webhooks/slack', to: 'slack#webhook'
end
