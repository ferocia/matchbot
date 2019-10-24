# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'
  resources :match, only: %i[create]

  namespace :game do
    get '/:id/leaderboard', to: 'game#leaderboard'
    get '/:id/matches', to: 'game#matches'
  end

  post 'slack/webhook', to: 'slack#webhook'
end
