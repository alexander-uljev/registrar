require 'registration_error'
# An abstract class to handle registration process. Connecting to different kinds of databases
# and performing datbase specific operations should be realised in subclasses. Comes with 
# features to ensure it's safety and consistency.
class AbstractRegistrar
  # Requires a hash of safety parameters. Hash must include allowed registrations interval 
  # (in minutes) as 'allowed_interval'.Fails if registration attempt interval is not a number.
  def initialize(safety_parameters)
    check_allowed_interval(safety_parameters) # Raises exception
	  # Connecting through subclass
  end
  
  # Main method to perform a registration. Requres a hash of form data and user ip as arguments.
  # The hash must include 'email', 'password' and 'confirm_password' key-value pairs. Runs 
  # injection and password matching checks. Creating user record and additional checks that
  # involves querying database should be realised in subclasses.
  def register(form_data, user_ip)
	  validate_ip(user_ip) # Raises exception
	  validate_email( form_data[:email] ) # Raises exception
    injection_check(form_data) # Raises exception    
	  passwords = form_passwords(form_data)
	  check_matching(passwords) # Raises exception
	  # Performing registration through subclass
  end
  
  # Closes connection with database after all registrations were finished. Should be realised
  # in subclasses.
  def finish
    #
  end
  
  private
    # Checks that _allowed_interval_ parameter is numeric. Raises exception or creates
	  # allowed_interval instance variable.
	  def check_allowed_interval(safety_parameters)
	    allowed_interval = safety_parameters[:allowed_interval]
	    unless allowed_interval.class.superclass == Numeric
	      fail("Allowed interval parameter passed is not a number. It was: #{allowed_interval}")
	    else 
	      @allowed_interval = allowed_interval
	    end	
	  end
	
	  # Runs a regexp check of passed user ip. Raises exception if ip does not match the pattern.
	  def validate_ip(user_ip)
	    # Regexp ip check
	    pattern = /([12]?[0-9]{1,2}\.){3}[12]?[0-9]{1,2}/ # 255.255.255.255
	    match = user_ip =~ pattern
	    fail("\"#{user_ip}\" is not a valid ip adress.") if match.equal? nil
	  end
    
	  # Runs a regexp check of passed email. Raises exception if ip does not match the pattern.
	  def validate_email(email)
	    # Regexp email check
	    pattern = /([a-z0-9]+[_-.]*)+@[a-z]+\.[a-z]{2,3}/
	    match = email.downcase =~ pattern
	    fail("\"#{email}\" is not a valid email adress.") if match.equal? nil
	  end
	
    # Checks if given hash of values include HTML tags, SQL code and other harmful values. 
	  # Raises exception in case of values before and after stripping do not match.
    def injection_check(data)
	    # Check
	    bad_values = #
	    fail("Injection attempt detected. Entries: #{bad_values}") unless bad_values.equal? nil	  
	  end
	
	  # Forms a hash that supports clear cheking error messages.
	  def form_passwords(form_data)
	    { 
	      :passwords => [ 
	        form_data['password'],
		      form_data['confirm_password']
	      ]
      }
	  end
	
	  # Looks up in database for the record with specified email. Returns true if it exists or
	  # false if it doesn't. Should be realised in a subclass.
	  def check_email(email)
	    # Don't
	  end
	
	  # Checks if the values provided match each other. Returns true if yes, false if no.
	  # Values must be a hash like { 'values_name' => [value_1, value_2, ..., value_n] }.
	  # This inconvinience supports clear error message for different kinds of checks.
	  def check_matching(values)
	    values.each |values_name, value| do
	      sample = value.pop
	      match = value.all? { |item| item == sample }
		    fail("#{values_name} provided do not match.") unless match.equal? true		
	    end
	  end
	
	  # A method with compact name that helped me to make this code shorter, simpler and clearer.
	  def fail(reason)
	    raise RegistrationError, reason
	  end
end

=begin TODO
  Study and implement proper exceptions       DONE
  Check regexps for possible adjustments      DONE
  
  Check email for validity 						        DONE
  Make code to parse form_data hash flexible  
=end