# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'

  post 'webhooks/slack', to: 'webhook#slack'

  post 'slack/event', to: 'slack#event'
  post 'slack/slash', to: 'slack#slash'
end
