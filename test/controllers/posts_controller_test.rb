require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post posts_url, params: { post: { address_city: @post.address_city, address_line_1: @post.address_line_1, address_line_2: @post.address_line_2, address_state: @post.address_state, address_zipcode: @post.address_zipcode, letter_id: @post.letter_id, payment_id: @post.payment_id, recipient_id: @post.recipient_id, sender_id: @post.sender_id } }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { address_city: @post.address_city, address_line_1: @post.address_line_1, address_line_2: @post.address_line_2, address_state: @post.address_state, address_zipcode: @post.address_zipcode, letter_id: @post.letter_id, payment_id: @post.payment_id, recipient_id: @post.recipient_id, sender_id: @post.sender_id } }
    assert_redirected_to post_url(@post)
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end
end
