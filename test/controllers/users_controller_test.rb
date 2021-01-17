require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should not be able to get user page without logging in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should not be able to post to users path without logging in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                               email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "another user shouldn't be able to view another user's edit page" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_path
  end

  test "another user shouldn't be able to patch to another user's page" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                               email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_path
  end 

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not be able to patch to give admin status" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { 
      user: { password: "password",
              password_confirmation: "password",
              admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
