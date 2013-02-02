require 'data_mapper'
require 'dm-postgres-adapter'
require 'will_paginate'
require 'will_paginate/data_mapper'

# Require all files in ./src/models
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each {|file| require file }

DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "postgres://localhost/thesisprog")

DataMapper::Property::String.length(255)

DataMapper.finalize