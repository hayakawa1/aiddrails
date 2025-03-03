require "test_helper"

class Individual::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get individual_messages_index_url
    assert_response :success
  end

  test "should get show" do
    get individual_messages_show_url
    assert_response :success
  end

  test "should get create" do
    get individual_messages_create_url
    assert_response :success
  end
end
