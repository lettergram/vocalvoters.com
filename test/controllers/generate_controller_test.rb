require "test_helper"

class GenerateControllerTest < ActionDispatch::IntegrationTest
  test "should get letter" do
    get generate_letter_url
    assert_response :success
  end
end
