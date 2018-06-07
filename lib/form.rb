require 'digest\bubblebabble'

# Easy-to-use class to validate and prepare for database insertion any form inputs within 
# one method call.
class Form

  attr_accessor :form
  
  NAMES = {
    
    :login => /login/,
    :password => /pass/,
    :email => /e-?mail/,
    :text => /(comment)|(about)|(body)|(text)/, # No need for checking
    :date => /date/,
    :birthday => /birthday/,
    :nickname => /nickname/,
    :tel => /tel/,
    :age => /age/,
    :number => /num/,
    :name => /name/,
    :zip => /(zip)|(postal)/,
    :address => /ad{1,2}res{1,2}/,
    :city => /city/,
    :country => /country/,
    :area => /(state)|(province)|(area)/,
    :url => /ur[li]/,    
    :ip => /ip/,
    :domain => /domain/,
  }
  
  TYPES = {
  
    :login     => ['nickname', 'login'],
    :password  => 'password'
    :email     => 'email',
    :telephone => 'tel',
    :date      => ['date', 'birthday'],
    :name      => ['name', 'city', 'country', 'area'],
    :number    => ['age', 'zip', 'postal'],
    :numbers   => 'number',
    :adress    => 'address',
    :ip        => 'ip',
    :url       => 'url'
  }
  
  PATTERNS = {
  
    :login     => /[A-z0-9_\-.]+/,
    :email     => /\w+[_.\-]?\w*@[a-z]{2,}\.[a-z]{2,3}/,
    :url       => /(https?:\/\/)?(\w+\.)+[a-z]{2,3}/,
    :password  => /[\w_\-.!?\\*$]+/,
    :name      => /([A-z]+ ?)+/,
    :address   => /([A-z0-9_\-.,\\\/]+)+/,
    :number    => /\d{1,6}/,
    :numbers   => /(\d+ ?)+/,
    :telephone => /\+?\d{1,3} ?\(?\d{1,7}\)?[ \-]?(\d*[ \-]?)*/,
    :ip        => /([0-9]{1,3}\.){3}[0-9]{1,3}/,
    :date      => /\d{1,4}[.\/-\\]\d{1,2}[.\/-\\]\d{1,4}/
  }
  
  # Requires form hash as a single argument. Form is read/writable.
  def initialize(form)
    @form = form
  end    
  
  # Main method to validate all the field values. It is capable of working with and
  # without of an argument. If argument is passed, it must be a copy (or equal hash) of
  # form object with the values substituted by value types. Valid types are specified in
  # TYPES constant. Returns true or exception.
  def validate(types=nil)
    @form.each |field, value| do
      field = assign_name field
      next if field.equal? :text
      type = ( types[field] or get_type field )      
      pattern = get_pattern type
      match value, pattern # Raises exception
    end
  end  
  
  # Looks up for a password key in the form hash, encrypts it's value and sores it.
  # Overwrites the original value. Uses SHA256 to digest the password. Returns encrypted
  # string.
  def encrypt_password(password_field=nil)
    password_field = find_field :password if password_field.equal? nil
    encrypt password_field
  end
  
  private
    
    # Matches passed input's name against a set of predifined names and returns it.
    def assign_name(field)
      NAMES.each |name, pattern| do
        return name if field.downcase.match? pattern
      end
    end
    
    # Returns a type string for input passed. It matches input's name against well-known
    # input's names like password, tel, date of birth. The match uses regexp, so the input
    # is not neccesseraly have to be equal to a defined-here name.
    def get_type(field)
      TYPES.each |type, name| do
        if name.is_a? Array then
          match = name.any? { |value| value.equal? field }
        else
          match = name.equal? field
        end
        return type if match.equal? true
      end
    end
    
    # Returns a regexp pattern for a passed type.
    def get_pattern(type)
      if type.equal? :login then
        [ PATTERNS[:login], PATTERNS[:email], PATTERNS[:telephone] ]
      else
        PATTERNS[type]
      end
    end
    
    # This method matches the value against passed pattern(s). Next, compares the length 
    # of matched string and original value. Returns true or exception.
    def match(value, pattern)
      value.strip!
      if pattern.is_a? Array then
        match = pattern.each |item| do
          match = value.match item
          break match unless match.equal? nil
        end
      else
        match = value.match pattern
      end      
      raise 'Problem' if match.equal? nil
      check = match[0].length.equal? value.length
      raise 'Problem' if check.equal? false
    end
    
    # Returns original field name or nil if it was not found in form.
    def find_field(name)
      @form.each |field, value| do
        return field if field.match? NAMES[name]          
      end
      nil
    end
    
    # Encrypts field's value and stores it overwriting original value. Returns encrypted string.
    def encrypt(field)
      @form[field] = Digest::SHA256.bubblebabble @form[field]
    end
end