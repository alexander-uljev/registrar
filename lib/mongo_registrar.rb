require_relative 'abstract_registrar'
require 'mongo'

# An extension that can work with Mongo database.
class MongoRegistrar < AbstractRegistrar
  # Uses parent method and extends it to connect to database. Requires _descriptor_,
  # _options_ and _safety parameters_. Descriptor must be an URI that points to the
  # database. Options must be a hash with at least two keys: user and password. For
  # the full description please refer to Mongo gem documentation. Also checks if the connection
  # was established and raises exception if it wasn't.
  def initialize(descriptor, options, safety_parameters)
    super(safety_parameters)
		@db = Mongo::Client.new(descriptor, options)
    check_connection # Raises exception
  end

  # A method that performs registrarion. Uses same method of a parent class and extends it
  # with various checks. Most of the checks raise exceptions. For specified exception
  # please refer to specified method's documentation. Returns a hash with user data
  # including record id.
  def register(form_data, user_ip)
    begin
      super(form_data, user_ip)
	  rescue ValidationError => e
	    @db[:bad_ip].insert_one(user_ip) # Read about Mongo Unique constraint
	    raise ValidationError, e.message
	  end
    check_email(form_data[:email]) # Raises exception
	  check_interval(user_ip) # Raises exception
	  user = form_user(form_data)
	  user = @db[:users].insert_one(user)
	  register_ip(user_ip)
    user
  end

  # Closes the database connection after all the registrations were completed
  def finish
    @db.close
  end

  private

    # Checks if MongoDB returned OK message after connecting. Raises exception if it didn't.
	  def check_connection
      state = @db.match(/\s/).pre_match
      unless state.equal? 'connection'
        fail("Failed to connect using specified descriptor. The error was: #{get_db_error}")
      end
    end

    # Checks if provided email is already stored in users table. Raises exception if it is.
    def check_email(email)
      user = @db[:users].find( { :email => email } )
      fail("#{email} is already registered.") unless user.equal? nil
    end

    # Gets error message from what MongoDB has returned for connection attempt.
    def get_db_error
      @db.match(/Error/).post_match
    end

    # Checks if user's ip adress has already been used for registration in last _n_ minutes.
    # Returns time in minutes till the next registration attempt or _false_ if there is no
    # interval violation.
    def check_interval(user_ip)
      record = @db[:registrations].find( { :ip => user_ip } )
      unless record.equal? nil
        reg_time = Time.new(record[:time]) # Can be moved to parent class
        interval =  (Time.now - reg_time).to_i / 60 # Minutes, no floating
        check = interval < @allowed_interval
        if check.equal? false then
          fail("#{user_ip} was already used to register an account. Next attempt will be available \
              in #{interval} minutes")
        end
      end
    end

    # Forms user hash for inserting in users table.
    def form_user # Can be moved to parent class
      {
        :email    => form_data['email'],
        :password => form_data['password'],
        :name     => form_data['name']       # Make proper greetings if it's nil
      }
    end

    # Stores user ip in registrations table after successful registrarion attempt to
    # support frequent registrations check feature.
    def register_ip(user_ip)
      registrations = @db[:registrations]
      ip_record = registrations.find( { :ip => user_ip } )
      if ip_record.equal? nil then
        ip_time = {         # Can be moved to parent class
          :ip   => user_ip,
          :time => Time.now # Check date format compability
        }
        registrations.insert_one(ip_time)
      else
        new_value = { :$set => { :time => Time.now } }
        registrations.update_one(ip_record, new_value) # Is this syntax correct?
      end
    end
  end

=begin TODO
    Authentication?

=end