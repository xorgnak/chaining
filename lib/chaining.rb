# frozen_string_literal: true

# load
require 'digest'
require 'sinatra/base'
require 'pstore'
require 'csv'
require 'json'
require 'redcarpet'
require 'ipfs-api'
require 'eqn'
require 'classifier'
require 'matrix'
require 'ruby-units'
require 'nickel'

module Chaining
  class Error < StandardError; end
  # Your code goes here...  
end

# ready
require_relative "chaining/version"

# aim
require_relative "chaining/dice"
require_relative "chaining/actor"
require_relative "chaining/coin"
require_relative "chaining/vm"
require_relative "chaining/db"
require_relative "chaining/fs"
require_relative "chaining/intake"
require_relative "chaining/brain"
require_relative "chaining/eqn"
require_relative "chaining/unit"
require_relative "chaining/wiki"
require_relative "chaining/here"
require_relative "chaining/cal"
require_relative "chaining/session"
require_relative "chaining/job"
require_relative "chaining/maid"
require_relative "chaining/carpet"
require_relative "chaining/cookie"
require_relative "chaining/deck"
# fire
require_relative "chaining/app"
require_relative "chaining/bot"

