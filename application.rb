#!/usr/bin/env ruby
# encoding: utf-8

require File.dirname(__FILE__) + '/environment.rb'

class BIONOMIAAPI < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :haml, :format => :html5
  set :public_folder, 'public'
  set :show_exceptions, false
  set :protection, :except => [:json_csrf]

  register Config

  include Pagy::Backend
  include Pagy::Frontend
  Pagy::DEFAULT[:items] = 30

  helpers Sinatra::BionomiaApi::Formatters
  helpers Sinatra::BionomiaApi::Queries
  helpers Sinatra::BionomiaApi::Reconcile
  helpers Sinatra::BionomiaApi::UserHelper
  helpers Sinatra::BionomiaApi::DatasetHelper

  register Sinatra::BionomiaApi::Controller::SearchController
  register Sinatra::BionomiaApi::Controller::ReconcileController

  not_found do
    if !content_type
      haml :oops
    else
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
  end

  error do
    if !content_type
      haml :oops
    else
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
  end

  run! if app_file == $0
end
