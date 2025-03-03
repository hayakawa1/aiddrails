require "test_helper"

class Company::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get company_messages_index_url
    assert_response :success
  end

  test "should get show" do
    get company_messages_show_url
    assert_response :success
  end

  test "should get create" do
    get company_messages_create_url
    assert_response :success
  end
end
