require 'test_helper'

class LoginTestTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "access website" do
    https!
    get "/users/sign_in"
    assert_response :success
    
    
  end
end
