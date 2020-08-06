require 'bundler'
require 'json'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'config'
require 'dwc_agent'
require 'yaml'
require 'elasticsearch'
require 'pagy'
require 'pagy/extras/arel'
require 'pagy/extras/array'
require 'pagy/extras/bootstrap'
require 'thin'
require 'require_all'
require 'uri'
require 'net/http'
require 'rack'
require 'rack/contrib'

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

require_all File.join(File.dirname(__FILE__), 'formatters')
require_all File.join(File.dirname(__FILE__), 'helpers')
require_all File.join(File.dirname(__FILE__), 'controllers')
