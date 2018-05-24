module VariablesForTest

  invalid_email = "foo#{ rand(2000) }"
  @valid_email = invalid_email + '@bar.ru'
  password_1 = 'foo'
  password_2 = password_1 + 'bar'
  
  @forms = {
  
    :valid => {
	  :email => valid_email,
	  :password => password_1,
	  :confirm_password => password_1
	},
	
    :injected => {
	  :email => 'alala@ololo.ru',
	  :password => 'no_way',
	  :confirm_password => 'no_way'
	},
	
	:invalid_email => {
	  :email => invalid_email,
	  :password => password_1,
	  :confirm_password => password_1
	},
	
	:missmatching_passwords => {
	  :email => valid_email,
	  :password => password_1,
	  :confirm_password => password_2
	}
  }
  
  @ip = {
    :valid   => '12.1.23.0',
    :invalid => '256.0.3.256'
  }
  
  @parameters = {
    :valid   => { allowed_interval: 30 },
    :invalid =>  { allowed_interval: 'sasa' }
  }
  
  @descriptor = {
    :valid   => 'mongodb://127.0.0.1:27017/test',
    :invalid => '/foo/bar'
  }
  
end