require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@user)
    get users_path

    assert_template 'users/index'
    assert_select 'div.pagination'

    first_page_of_users = User.paginate(page: 1)

    first_page_of_users.each do |user|
      # должна быть ссылка на юзера
      assert_select 'a[href=?]', user_path(user), text: user.name

      unless user.admin?
        # должна быть ссылка на удаление юзера а так же метод delete
        assert_select 'a[href=?]',user_path(user), text: 'delete', method: :delete
      end
    end
  end

  test "should delete user when logged in as admin" do
    log_in_as(@user)
    get users_path

    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path

    assert_select 'a', text: 'delete', count: 0
  end
end
