require "application_system_test_case"

class RecipientsTest < ApplicationSystemTestCase
  setup do
    @recipient = recipients(:one)
  end

  test "visiting the index" do
    visit recipients_url
    assert_selector "h1", text: "Recipients"
  end

  test "creating a Recipient" do
    visit recipients_url
    click_on "New Recipient"

    fill_in "Address city", with: @recipient.address_city
    fill_in "Address line 1", with: @recipient.address_line_1
    fill_in "Address line 2", with: @recipient.address_line_2
    fill_in "Address state", with: @recipient.address_state
    fill_in "Address zipcode", with: @recipient.address_zipcode
    fill_in "District", with: @recipient.district
    fill_in "Email address", with: @recipient.email_address
    fill_in "Level", with: @recipient.level
    fill_in "Name", with: @recipient.name
    fill_in "Number fax", with: @recipient.number_fax
    fill_in "Number phone", with: @recipient.number_phone
    fill_in "Position", with: @recipient.position
    fill_in "State", with: @recipient.state
    click_on "Create Recipient"

    assert_text "Recipient was successfully created"
    click_on "Back"
  end

  test "updating a Recipient" do
    visit recipients_url
    click_on "Edit", match: :first

    fill_in "Address city", with: @recipient.address_city
    fill_in "Address line 1", with: @recipient.address_line_1
    fill_in "Address line 2", with: @recipient.address_line_2
    fill_in "Address state", with: @recipient.address_state
    fill_in "Address zipcode", with: @recipient.address_zipcode
    fill_in "District", with: @recipient.district
    fill_in "Email address", with: @recipient.email_address
    fill_in "Level", with: @recipient.level
    fill_in "Name", with: @recipient.name
    fill_in "Number fax", with: @recipient.number_fax
    fill_in "Number phone", with: @recipient.number_phone
    fill_in "Position", with: @recipient.position
    fill_in "State", with: @recipient.state
    click_on "Update Recipient"

    assert_text "Recipient was successfully updated"
    click_on "Back"
  end

  test "destroying a Recipient" do
    visit recipients_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Recipient was successfully destroyed"
  end
end
