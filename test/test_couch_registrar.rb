require 'unit/test'
require 'couch_registrar'
require_relative 'variables_for_test'

class TestCouchRegistrar < Test::Unit::TestCase
  include VariablesForTest
  
  # db = Mongo::Client.new('mongodb://127.0.0.1:27017/test')
  @users_table = db[:users]
  @registrations_table = db[:registrations]
  
  def test_initialization
    # assert_nothing_raised { @mregistrar =  MongoRegistrar.new(@valid_descriptor, @valid_parameters) }
    # assert_raises(Exception) { MongoRegistrar.new(@invalid_descriptor, @valid_parameters) }
  end  
  
  def test_registration
    # assert_nothing_raised { @mregistrar.register(@forms[:valid], @valid_ip) }
  end
  
  def test_injection
    # assert_raises(Exception) { @mregistrar.register(@forms['injected'], @valid_ip) }
    # ip_record = @bad_ip_table.find( { :ip => @valid_ip } )
    # ip_reg_time = Time.new(ip_record[:time]).to_i
    # assert( ip_reg_time <= Time.now.to_i + 1 )
  end
  
  def test_email_check
    # @users_table.insert_one(@valid_email)
    # assert_raises(Exception) { @mregistrar.register(@valid_email, @valid_ip) }
  end
  
  def test_interval_check
    # reg = { 
    #   :ip => @valid_ip,
    #   :time => Time.now
    # }
    # @registrations_table.insert_one(reg)
    # assert_raises(Exception) { @mregistrar.register(@valid_email, @valid_ip) }
  end
  
end