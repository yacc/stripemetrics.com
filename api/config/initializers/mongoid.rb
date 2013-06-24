require 'bundler/setup'
require 'mongoid'

module Stripemetrics 
  class Api < Grape::API

    Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))

  end
end

