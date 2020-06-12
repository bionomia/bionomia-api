#!/usr/bin/env ruby
# encoding: utf-8

require File.dirname(__FILE__) + '/environment.rb'

class BIONOMIAAPI < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :show_exceptions, false

  register Config
  register Sinatra::CrossOrigin

  include Pagy::Backend
  include Pagy::Frontend
  Pagy::VARS[:items] = 30

  helpers Sinatra::Api::Formatters
  helpers Sinatra::BionomiaApi::Queries
  helpers Sinatra::BionomiaApi::Reconcile
  helpers Sinatra::BionomiaApi::UserHelpers

  register Sinatra::BionomiaApi::Controller::SearchController
  register Sinatra::BionomiaApi::Controller::ReconcileController

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Client-Security-Token"
    200
  end

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
