require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password: "foo",
                               password_confirmation: "bar" }
    end

    assert_template 'users/new'
  end

  test "should contain error message" do
    get signup_path

    post users_path, user: { name:                 "",
                             email:                "user@invalid",
                             password:             "foo",
                             password_confirmation: "bar"}
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count' do
      post_via_redirect users_path, user: { name: "User",
                               email: "nastya123@email.com",
                               password: "qwerty",
                               password_confirmation: "qwerty"}
    end

    assert_template 'users/show'
    assert is_logged_in?
  end
end
