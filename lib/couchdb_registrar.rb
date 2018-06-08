require 'couchdb-client'
require 'abstract_registrar'

module Registrar

  class CouchDbRegistrar < AbstractRegistrar
    # Uses parent method and extends it to connect to database. Requires _descriptor_,
    # _options_ and _safety parameters_. Descriptor must be an URI string or array of URI strings
    # that points to the database. Options must be a hash with at least two keys: user and password.
    # For the full description please refer to Mongo gem documentation. Also checks if the connection
    # was established and raises exception if it wasn't.
    def initialize(host, port, user, password, safety_parameters)
      super safety_parameters
      client = CouchDB.connect host, port
      # check_connection
      @users, @registrations = client.db 'users', client.db 'registrations'
    end

    # A method that performs registrarion. Uses same method of a parent class and extends it with 
    # various checks. Most of the checks raise exceptions. For specified exception please refer
    # to specified method's documentation. Returns a hash with user data including record id.
    def register(form_data, user_ip)
      super form_data, user_ip
      check_email form_data[:email] # Raises exception
      check_interval user_ip # Raises exception
      user = form_user form_data # This method defined in parent class
      user = CouchDB::Document.new(@users, user).save
      register_ip user_ip
      user
    end

    # Closes the database connection after all the registrations were completed.
    def finish
      @db.close
    end

    private
    
      # Checks if CouchDB returned OK message after connecting. Raises exception if it didn't.
      def check_connection
        #
      end

      # Checks if provided email is already stored in users table. Raises exception if it is.
      def check_email(email)
        # Read about how to find a record in CouchDB
        # record = @users.find :email => email 
        super email, record
      end

      # Gets error message from what MongoDB has returned for connection attempt.
      def get_db_error
        #
      end

      # Checks if user's ip adress has already been used for registration in last _n_ minutes.
      # Returns time in minutes till the next registration attempt or _false_ if there is no
      # interval violation.
      def check_interval(user_ip)
        # record = @db[:registrations].find( { :ip => user_ip } )
        super record
      end

      # Stores user ip in registrations table after successful registrarion attempt to
      # support frequent registrations check feature.
      def register_ip(user_ip)
        # ip_record = registrations.find( { :ip => user_ip } )
        if ip_record.equal? nil then
          ip_time = super
          registrations.insert_one ip_time
        else
          new_value = { :$set => { :time => Time.now } }
          registrations.update_one(ip_record, new_value) # Is this syntax correct?
        end
      end
  end
end