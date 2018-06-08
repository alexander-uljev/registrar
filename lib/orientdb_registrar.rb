require 'orientdb_client'
require 'abstract_registrar'

module Registrar

  # An extension to support working with Orient database. Uses _orientdb(dash)client_ gem. Supports
  # 2 public methods - register and finish. The rest of the work happens on the background.
  class OrientDbRegistrar < AbstractRegistrar

    # Uses parent method and extends it to connect to database. Requires db_parameters, and
    # safety_parameters. db_parameters must be an array including host, port, user, password, db_name.
    # safety_parameters are described in AbstractRegistrar class documentation. Checks if the 
    # connection was established and raises exception if it wasn't.
    def initialize(db_parameters, safety_parameters)
      super safety_parameters
      host, port, user, password, db_name = db_parameters
      @client = OrientDBClient.client host, port
      @client.connect user, password, db_name
      check_connection
    end

    # A method that performs registrarion. Uses same method of a parent class and extends it with 
    # various checks. Most of the checks raise exceptions. For specified exception please refer
    # to specified method's documentation. Returns a hash with user data including record id.
    def register(form_data, user_ip)
      begin
        super form_data, user_ip
      rescue ValidationError => e
        @client.query("INSERT #{user_ip} in Bad_IPs")
        raise ValidationError, e.message
      end
      check_email form_data[:email] # Raises exception
      check_interval user_ip # Raises exception
      user = form_user form_data # This method defined in parent class
      user = @client.query "INSERT #{user} in Uers"
      register_ip user_ip
      user
    end

    # Closes the database connection after all the registrations were completed.
    def finish
      @client.disconnect
    end

    private

      # Checks if MongoDB returned OK message after connecting. Raises exception if it didn't.
      def check_connection
        unless @client.connected?
          fail "Failed to connect using specified descriptor. The error was: #{get_db_error}"
        end
      end

      # Checks if provided email is already stored in users table. Raises exception if it is.
      def check_email(email)
        record = @client.query "SELECT * from Users where email=#{email}"
        super email, record
      end

      # Gets error message from what MongoDB has returned for connection attempt.
      def get_db_error
        # @db.match(/Error/).post_match
      end

      # Checks if user's ip adress has already been used for registration in last _n_ minutes.
      # Returns time in minutes till the next registration attempt or _false_ if there is no
      # interval violation.
      def check_interval(user_ip)
        record = @client.query "SELECT time from Registrations where ip=#{user_ip}"
        super(record)
      end

      # Stores user ip in registrations table after successful registrarion attempt to
      # support frequent registrations check feature.
      def register_ip(user_ip)
        ip_record = @client.query "SELECT id from Registrations where ip=#{user_ip}"
        if ip_record.equal? nil then
          ip_time = super
          @client.query "INSERT #{ip_time} in Registrations"
        else
          @client.query "UPDATE Registrations set time=#{Time.now} where id=#{ip_record}"
        end
      end
  end
end