require "neuroprok/version"

module Neuroprok
  mattr_accessor :parent_controller
  @@parent_controller = "ApplicationController"
end
