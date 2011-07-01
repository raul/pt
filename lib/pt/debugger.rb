# Nasty tricks to debug the interaction with the Pivotal Tracker API

module RestClient
  class Request
    
    alias_method :rest_client_execute, :execute
    def execute &block
      puts "\nRequest: #{method.upcase} #{url}"
      rest_client_execute &block
    end
  end
end

module HappyMapper
  module ClassMethods
    alias_method :pivotal_tracker_parse, :parse
    def parse(xml, options={})
      xml = xml.to_s if xml.is_a?(RestClient::Response)
      puts "\nResponse:\n#{xml}\n"
      pivotal_tracker_parse(xml, options)
    end
  end
end
