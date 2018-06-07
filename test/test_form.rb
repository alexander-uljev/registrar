require 'unit/test'
require 'form'
require_relative 'variables_for_test'

class TestForm < Test::Unit::TestCase

  include VariablesForTest
  @f = Form.new @form[:valid]
  
  def test_validation
    assert_nothing_raised { form.validate }
    @f.form = @form[:invalid]
    assert_raises Exception { form.validate }
  end
  
  def test_password_encryption
    @f.form = @form[:valid]
    assert_equal @f.encrypt_password, "xerad-kytuk-ropuz-zacem-zyven-recef-solef-bobof-gegog-daryl-binem-fuzop-buvam-polym-memek-kynop-vexax"
    # assert_nothing_raised { form.encrypt_password }
  end

end