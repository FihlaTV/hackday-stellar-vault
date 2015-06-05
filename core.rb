require 'excon'

raise "No STELLAR_CORE_URL" if ENV["STELLAR_CORE_URL"].blank?

module Core
  Web = Excon.new(ENV["STELLAR_CORE_URL"])
end
