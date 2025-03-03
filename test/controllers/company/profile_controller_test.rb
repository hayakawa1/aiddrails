require "test_helper"

class Company::ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get company_profile_show_url
    assert_response :success
  end

  test "should get edit" do
    get company_profile_edit_url
    assert_response :success
  end

  test "should get update" do
    get company_profile_update_url
    assert_response :success
  end
end
