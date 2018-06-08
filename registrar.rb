require 'abstract_registrar'

module Registrar

  class Driver
  
  DRIVERS = [
    'mongodb',
    'couchdb',
    'orientdb'
  ]
  
  def load(driver)
    raise "\"#{driver}\" is not supported.\r\n#{puts DRIVERS}" unless DRIVERS.include? name
    @class_name = name + '_registrar'
    require_relative @class_name
  end
  
  def instance
    raise "Driver not loaded. Use load method first" if @class_name.empty?
    klass = case @class_name
      when 'mongodb_registrar' then MongoDbRegistrar
      when 'couchdb_registrar' then CouchDbRegistrar
      when 'orientdb_registrar' then OrientDbRegistrar
    end
    klass.new
  end
  
end


=begin future
  
  interface?  
  CouchDB     DONE
  OrientDB    DONE
  FormParser  
    Move the checks to here  
  
  SQL?
  
  Turn it to a gem
  
=end

=begin

   def self.driver(name)
    raise "\"#{name}\" is not a supported database" unless DRIVERS.include? name
    class_name = name + '_registrar'
    require_relative class_name    
    
  end
  
  def with_features(feature, parameters)
    if feature.equal? 'interval_check' then
      #
    end
    new
  end

=end