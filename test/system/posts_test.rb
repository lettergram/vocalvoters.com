require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end

  test "creating a Post" do
    visit posts_url
    click_on "New Post"

    fill_in "Address city", with: @post.address_city
    fill_in "Address line 1", with: @post.address_line_1
    fill_in "Address line 2", with: @post.address_line_2
    fill_in "Address state", with: @post.address_state
    fill_in "Address zipcode", with: @post.address_zipcode
    fill_in "Letter", with: @post.letter_id
    fill_in "Payment", with: @post.payment_id
    fill_in "Recipient", with: @post.recipient_id
    fill_in "Sender", with: @post.sender_id
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "updating a Post" do
    visit posts_url
    click_on "Edit", match: :first

    fill_in "Address city", with: @post.address_city
    fill_in "Address line 1", with: @post.address_line_1
    fill_in "Address line 2", with: @post.address_line_2
    fill_in "Address state", with: @post.address_state
    fill_in "Address zipcode", with: @post.address_zipcode
    fill_in "Letter", with: @post.letter_id
    fill_in "Payment", with: @post.payment_id
    fill_in "Recipient", with: @post.recipient_id
    fill_in "Sender", with: @post.sender_id
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "destroying a Post" do
    visit posts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Post was successfully destroyed"
  end
end
