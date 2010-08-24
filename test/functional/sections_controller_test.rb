require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  setup do
    @section = sections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create section" do
    assert_difference('Section.count') do
      post :create, :section => @section.attributes
    end

    assert_redirected_to section_path(assigns(:section))
  end

  test "should show section" do
    get :show, :id => @section.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @section.to_param
    assert_response :success
  end

  test "should update section" do
    put :update, :id => @section.to_param, :section => @section.attributes
    assert_redirected_to section_path(assigns(:section))
  end

  test "should destroy section" do
    assert_difference('Section.count', -1) do
      delete :destroy, :id => @section.to_param
    end

    assert_redirected_to sections_path
  end
end
