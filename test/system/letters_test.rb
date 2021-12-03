require "application_system_test_case"

class LettersTest < ApplicationSystemTestCase
  setup do
    @letter = letters(:letter_one)
  end

  test "visiting the index" do
    visit letters_url
    assert_selector "h1", text: "Letters"
  end

  test "creating a Letter" do
    visit letters_url
    click_on "New Letter"

    fill_in "Body", with: @letter.body
    fill_in "Category", with: @letter.category
    fill_in "Policy or law", with: @letter.policy_or_law
    fill_in "Sentiment", with: @letter.sentiment
    fill_in "User", with: @letter.user_id
    click_on "Create Letter"

    assert_text "Letter was successfully created"
    click_on "Back"
  end

  test "updating a Letter" do
    visit letters_url
    click_on "Edit", match: :first

    fill_in "Body", with: @letter.body
    fill_in "Category", with: @letter.category
    fill_in "Policy or law", with: @letter.policy_or_law
    fill_in "Sentiment", with: @letter.sentiment
    fill_in "User", with: @letter.user_id
    click_on "Update Letter"

    assert_text "Letter was successfully updated"
    click_on "Back"
  end

  test "destroying a Letter" do
    visit letters_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Letter was successfully destroyed"
  end
end
