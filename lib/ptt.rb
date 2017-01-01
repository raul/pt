require 'rubygems'

module PTT
  class InputError < StandardError; end
  VERSION = '1.0.1'
end

require 'tracker_api'
require 'ptt/client'
require 'ptt/data_row'
require 'ptt/data_table'
require 'ptt/ui'
