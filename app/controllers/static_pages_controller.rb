require 'stripe'
include ApplicationHelper
class StaticPagesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create_payment_intent]
  
  def home
    
    @stripe_pk = ENV['STRIPE_PUBLISHABLE_KEY_VOCALVOTERS']
    
    @shared_letter_id = ""
    if params.has_key?(:letter_id)
      @shared_letter_id = params[:letter_id]
    end

    @referral_org_logo_link = ""
    @referral_org_id = ""
    if params.has_key?(:referral_org_id)
      org = Organization.find_by(id: params[:referral_org_id])
    else
      if current_user.present? and current_user.organization.present?
        org = current_user.organization
      else
        org = Organization.all.first
      end
    end


    @referral_org_id = org.id
    @referral_org_name = org.name
    @referral_org_logo_link = org.logo_link
    @referral_org_description = org.description
    @generation_option = org.generation_option
    
    @current_user_id = 1
    if current_user.present?
      @current_user_id = current_user.id
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def privacy
  end

  def terms
  end

  def partner
  end


  def create_payment_intent    
    Stripe.api_key = ENV['STRIPE_SECRET_KEY_VOCALVOTERS']
    
    # Create a PaymentIntent with amount and currency
    # TODO: Make more robust
    org = 'VocalVoters'
    if params.has_key? 'org'
      org = params['org']
    end
    
    payment_intent = Stripe::PaymentIntent.create({
      amount: calculate_order_amount(params['item'], params['count']),
      currency: 'usd',
      payment_method_types: ['card'],
      receipt_email: params['email'],
      description: org,
      metadata: { organization: org }
    })
    
    @payment_info = payment_intent['client_secret']

    respond_to do |format|
      format.json { @payment_info }
    end    
  end

  private

    def calculate_order_amount(item, count, processing=200)

      if not count.present? or not item.present?
        return 0
      end
      
      if ['Priority Mail'].include? item
        return 300 * count + processing
      elsif ['Letter', 'Letters'].include? item
        return 200 * count + processing
      elsif ['Fax', 'Faxes'].include? item
        return 100 * count + processing
      elsif ['Email', 'Emails'].include? item
        return 100 * count + processing
      end
    end

    def is_number? string
      true if Float(string) rescue false
    end
end
