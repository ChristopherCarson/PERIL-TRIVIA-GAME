require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  test "access website" do
    https!
    get "/users/sign_in"
    assert_response :success
    
  end
end
