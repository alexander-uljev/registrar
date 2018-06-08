require_relative 'registration_error'

module Registrar

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
    def register(form, user_ip)
      validate_ip user_ip # Raises exception
      form = Form.new form
      form.validate
      form.encrypt_password
      passwords = form_passwords form
      check_matching passwords # What if only one password is included in form?
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
          fail "Allowed interval parameter passed is not a number. It was: #{allowed_interval}"
        else 
          @allowed_interval = allowed_interval
        end	
      end
    
      # Runs a regexp check of passed user ip. Raises exception if ip does not match the pattern.
      def validate_ip(user_ip)
        # Regexp ip check
        pattern = Form::PATTERNS[:ip]
        fail "\"#{user_ip}\" is not a valid ip adress." unless user_ip.match? pattern
      end
      
      # Forms a hash that supports clear cheking error messages.
      def form_passwords(form) # Implement this in Form class
        { 
          :passwords => [ 
            form['password'],
            form['confirm_password']
          ]
        }
      end
    
      # Checks if the values provided match each other. Returns true if yes, false if no.
      # Values must be a hash like { 'values_name' => [value_1, value_2, ..., value_n] }.
      # This inconvinience supports clear error message for different kinds of checks.
      def check_matching(values) # Move this check to Form class
        values.each |values_name, value| do
          sample = value.pop
          match = value.all? { |item| item == sample }
          fail "#{values_name} provided do not match." unless match.equal? true
        end
      end
      
      # Looks up in database for the record with specified email. Returns true if it exists or
      # false if it doesn't. Should be realised in a subclass.
      def check_email(email, record)
        # Look for the record in a database
        fail "#{email} is already registered." unless record.equal? nil
      end
      
      # Partialy released. Checks time of user's last registration attempt and fails if it's less
      # then allowed.
      def check_interval(record)
        # Find a record in database
        unless record.equal? nil
          reg_time = Time.new record[:time] # Can be moved to parent class
          interval =  (Time.now - reg_time).to_i / 60 # Minutes, no floating
          check = interval < @allowed_interval
          if check.equal? false then
            fail "#{user_ip} was already used to register an account. Next attempt will be available \
                in #{interval} minutes"
          end
        end
      end
    
      # Forms user hash for inserting in users table.
      def form_user(form)
        {
          :email    => form['email'],
          :password => form['password'],
          :name     => form['name']       # Make proper greetings if it's nil
        }
      end
      
      # A draft. When released, stores an IP address and time in a database to support frequent
      # registration check feature.
      def register_ip(user_ip)
        # Checking database for existing record
        {
          :ip   => user_ip,
          :time => Time.now # Check date format compability
        }
        # Inserting or updating a record
      end    
    
      # A method with compact name that helped me to make this code shorter, simpler and clearer.
      def fail(reason)
        raise RegistrationError, reason
      end
  end
end
=begin TODO
  Study and implement proper exceptions       DONE
  Check regexps for possible adjustments      DONE
  Move check_matching and form_user to Form
  Check email for validity 						        DONE
  Make code to parse form hash flexible       DONE
=end