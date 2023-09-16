require 'bundler'
require 'active_support/all'
require 'json'
require 'sinatra/base'
require 'sinatra/multi_route'
require 'config'
require 'dwc_agent'
require 'yaml'
require 'tilt/haml'
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
require 'rack/protection'

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

require_all File.join(File.dirname(__FILE__), 'formatters')
require_all File.join(File.dirname(__FILE__), 'helpers')
require_all File.join(File.dirname(__FILE__), 'controllers')
