require "test_helper"

class Company::JobsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get company_jobs_index_url
    assert_response :success
  end

  test "should get show" do
    get company_jobs_show_url
    assert_response :success
  end

  test "should get new" do
    get company_jobs_new_url
    assert_response :success
  end

  test "should get create" do
    get company_jobs_create_url
    assert_response :success
  end

  test "should get edit" do
    get company_jobs_edit_url
    assert_response :success
  end

  test "should get update" do
    get company_jobs_update_url
    assert_response :success
  end

  test "should get destroy" do
    get company_jobs_destroy_url
    assert_response :success
  end
end
