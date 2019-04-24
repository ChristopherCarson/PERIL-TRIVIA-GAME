require 'test_helper'

class LoginTestTest < ActionDispatch::IntegrationTest
  test "access website" do
    https!
    get "/users/sign_in"
    assert_response :success
    
  end
end
