require "test_helper"

class Individual::MatchingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get individual_matching_index_url
    assert_response :success
  end
end
