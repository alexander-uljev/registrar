module Registrar

  class RegistrationError < StandartException
  end
  
  class ValidationError < RegistrationError
  end
  
end