require 'rubygems'

module PT
  class InputError < StandardError; end
  VERSION = '0.7.3'
end

require 'pt/client'
require 'pt/data_row'
require 'pt/data_table'
require 'pt/ui'
