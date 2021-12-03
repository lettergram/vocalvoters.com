class PaymentsController < ApplicationController
  
  # POST endpoint for stripe webhook
  # If your controller accepts requests other than Stripe webhooks,
  # you'll probably want to use `protect_from_forgery` to add CSRF
  # protection for your application. But don't forget to exempt
  # your webhook route!
  protect_from_forgery except: :webhook  
  def webhook
    payload = request.body.read
    event = nil
    
    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render status: :bad_request, nothing: true 
      return
    end
    
    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object # contains a Stripe::PaymentIntent
      # Then define and call a method to handle the successful payment intent.
      # handle_payment_intent_succeeded(payment_intent)
      require 'json'
    when 'payment_method.attached'
      payment_method = event.data.object # contains a Stripe::PaymentMethod
    # Then define and call a method to handle the successful attachment of a PaymentMethod.
    # handle_payment_method_attached(payment_method)
    # ... handle other event types
    else
      puts "Unhandled event type: #{event.type}"
    end
    
    render status: :ok, json: "Success: No Failures"
  end
      
end
