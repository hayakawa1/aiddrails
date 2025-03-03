require "test_helper"

class Individual::ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get individual_profile_show_url
    assert_response :success
  end
end
