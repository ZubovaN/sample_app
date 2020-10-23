require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    # users соответствует имени файла с тестовыми данными users.yml,
    # а сим-вол :michael ссылается на пользователя с ключом
    @user = users(:michael)
  end

  test "the truth" do
    get login_path

    assert_template 'sessions/new'

    post login_path, session: { email:    "sworfish@email.com",
                                password: "12343234"
    }

    assert_template 'sessions/new'
    assert_not flash.empty?

    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, session:{ email: "michael@example.com",
                               password: "password"
    }
    assert is_logged_in?
    assert_redirected_to @user

    # открыть страницу на которую был redirect_to
    follow_redirect!
    assert_template 'users/show'

    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    delete logout_path
    assert_not is_logged_in?

    assert_redirected_to root_path
    follow_redirect!

    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0




  end
end
