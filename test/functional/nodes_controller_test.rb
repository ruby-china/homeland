require 'test_helper'

class NodesControllerTest < ActionController::TestCase
  setup do
    @node = nodes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create node" do
    assert_difference('Node.count') do
      post :create, :node => @node.attributes
    end

    assert_redirected_to node_path(assigns(:node))
  end

  test "should show node" do
    get :show, :id => @node.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @node.to_param
    assert_response :success
  end

  test "should update node" do
    put :update, :id => @node.to_param, :node => @node.attributes
    assert_redirected_to node_path(assigns(:node))
  end

  test "should destroy node" do
    assert_difference('Node.count', -1) do
      delete :destroy, :id => @node.to_param
    end

    assert_redirected_to nodes_path
  end
end
