#!/usr/bin/env ruby
# encoding: utf-8

require File.dirname(__FILE__) + '/environment.rb'

class BIONOMIAAPI < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :show_exceptions, false
  set :protection, :except => [:json_csrf]

  register Config

  include Pagy::Backend
  include Pagy::Frontend
  Pagy::DEFAULT[:items] = 30

  helpers Sinatra::BionomiaApi::Formatters
  helpers Sinatra::BionomiaApi::Queries
  helpers Sinatra::BionomiaApi::Reconcile
  helpers Sinatra::BionomiaApi::UserHelpers

  register Sinatra::BionomiaApi::Controller::SearchController
  register Sinatra::BionomiaApi::Controller::ReconcileController

  not_found do
    content_type "application/json", charset: 'utf-8'
    status 404
    {
      errors: [
        {
          status: 404
        }
      ]
    }.to_json
  end

  error do
    content_type "application/json", charset: 'utf-8'
    status 503
    {
      errors: [
        {
          status: 503
        }
      ]
    }.to_json
  end

  run! if app_file == $0
end
