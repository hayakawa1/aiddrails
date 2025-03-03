require "test_helper"

class Company::MatchingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get company_matching_index_url
    assert_response :success
  end

  test "should get show" do
    get company_matching_show_url
    assert_response :success
  end

  test "should get like" do
    get company_matching_like_url
    assert_response :success
  end
end
