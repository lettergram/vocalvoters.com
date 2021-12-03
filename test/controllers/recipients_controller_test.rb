require "test_helper"

class RecipientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipient = recipients(:one)
  end

  test "should get index" do
    get recipients_url
    assert_response :success
  end

  test "should get new" do
    get new_recipient_url
    assert_response :success
  end

  test "should create recipient" do
    assert_difference('Recipient.count') do
      post recipients_url, params: { recipient: { address_city: @recipient.address_city, address_line_1: @recipient.address_line_1, address_line_2: @recipient.address_line_2, address_state: @recipient.address_state, address_zipcode: @recipient.address_zipcode, district: @recipient.district, email_address: @recipient.email_address, level: @recipient.level, name: @recipient.name, number_fax: @recipient.number_fax, number_phone: @recipient.number_phone, position: @recipient.position, state: @recipient.state } }
    end

    assert_redirected_to recipient_url(Recipient.last)
  end

  test "should show recipient" do
    get recipient_url(@recipient)
    assert_response :success
  end

  test "should get edit" do
    get edit_recipient_url(@recipient)
    assert_response :success
  end

  test "should update recipient" do
    patch recipient_url(@recipient), params: { recipient: { address_city: @recipient.address_city, address_line_1: @recipient.address_line_1, address_line_2: @recipient.address_line_2, address_state: @recipient.address_state, address_zipcode: @recipient.address_zipcode, district: @recipient.district, email_address: @recipient.email_address, level: @recipient.level, name: @recipient.name, number_fax: @recipient.number_fax, number_phone: @recipient.number_phone, position: @recipient.position, state: @recipient.state } }
    assert_redirected_to recipient_url(@recipient)
  end

  test "should destroy recipient" do
    assert_difference('Recipient.count', -1) do
      delete recipient_url(@recipient)
    end

    assert_redirected_to recipients_url
  end
end
