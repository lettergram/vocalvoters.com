require "test_helper"

class FaxesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fax = faxes(:one)
  end

  test "should get index" do
    get faxes_url
    assert_response :success
  end

  test "should get new" do
    get new_fax_url
    assert_response :success
  end

  test "should create fax" do
    assert_difference('Fax.count') do
      post faxes_url, params: { fax: { letter_id: @fax.letter_id, number_fax: @fax.number_fax, payment_id: @fax.payment_id, recipient_id: @fax.recipient_id, sender_id: @fax.sender_id } }
    end

    assert_redirected_to fax_url(Fax.last)
  end

  test "should show fax" do
    get fax_url(@fax)
    assert_response :success
  end

  test "should get edit" do
    get edit_fax_url(@fax)
    assert_response :success
  end

  test "should update fax" do
    patch fax_url(@fax), params: { fax: { letter_id: @fax.letter_id, number_fax: @fax.number_fax, payment_id: @fax.payment_id, recipient_id: @fax.recipient_id, sender_id: @fax.sender_id } }
    assert_redirected_to fax_url(@fax)
  end

  test "should destroy fax" do
    assert_difference('Fax.count', -1) do
      delete fax_url(@fax)
    end

    assert_redirected_to faxes_url
  end
end
