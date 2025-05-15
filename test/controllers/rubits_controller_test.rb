require "test_helper"

class RubitsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get rubits_index_url
    assert_response :success
  end
end
