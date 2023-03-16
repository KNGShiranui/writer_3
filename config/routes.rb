# frozen_string_literal: true

Rails.application.routes.draw do
  resources :documents do
    resources :versions, only: %i[show update], module: :documents
    resources :changes, only: %i[show], module: :documents
  end
end
