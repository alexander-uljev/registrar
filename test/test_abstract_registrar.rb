require 'abstract_registrar'
require 'test/unit'
require_relative 'variables_for_test'

class TestAbstractRegistrar < Test::Unit::TestCase
  include VariablesForTest
  
  def test_initialization
    assert_nothing_raised { @registrar =  AbstractRegistrar	.new(@valid_parameters), \
	                        'Everything fails if this fails' } # Think again
    assert_raises(Exception) { AbstractRegistrar.new(@invalid_parameters) }
  end
  
  def test_registration
    assert_nothing_raised { @registrar.register(@forms[:valid], @valid_ip) }    
  end
  
  def test_invalid_ip
	assert_raises(Exception) { @registrar.register(@forms[:valid], @invalid_ip) }
	assert_raises(Exception) { @registrar.register(@forms[:valid], @not_ip) }  
  end
  
  def test_invalid_email
    assert_raises(Exception) { @registrar.register(@forms[:bad_email], @valid_ip) }  
  end
  
  def test_injection_check
    pass  
  end
  
  def test_password_missmatch
    assert_raises(Exception) { @registrar.register(@forms[:missmatching_passwords], @valid_ip) }  
  end  
end