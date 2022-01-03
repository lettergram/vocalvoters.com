require 'stripe'
include ApplicationHelper
class StaticPagesController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create_payment_intent]
  
  def home
    
    @stripe_pk = ENV['STRIPE_PUBLISHABLE_KEY_VOCALVOTERS']

    @sentiment_val_map = {
      -1.0 => ["Very Opposed", -1.0],
      -0.5 => ["Opposed", -0.5],
      0.0 => ["Neutral", 0.0],
      0.5 => ["Support", 0.5],
      1.0 => ["Very Supportive", 1.0]
    }
    @sentiment_phrase_map = {
      "Very Opposed" => ["Very Opposed", -1.0],
      "Opposed" => ["Opposed", -0.5],
      "Neutral" => ["Neutral", 0.0],
      "Support" => ["Support", 0.5],
      "Very Supportive" => ["Very Supportive", 1.0]
    }

    @selected_category = params[:category]
    @options_category = []+Letter.distinct.pluck('lower(category)')
    
    @selected_sentiment = nil
    @options_sentiment = []

    @selected_policy_or_law = nil
    @options_policy_or_law = []      
          
    
    # Don't bother preloading unless category selected
    if @selected_category.present?

      #### DETERMINE THE SENTIMENT IF AVAILABLE #####
      
      available_sentiment = Letter.where(
	"category LIKE lower(?)", "%#{@selected_category}%"
      ).distinct.order(sentiment: :desc).pluck(:sentiment)
      available_sentiment.each { |sentiment|
        @options_sentiment.append(@sentiment_val_map[sentiment])
      }

      if params.has_key? :sentiment
        if is_number?(params[:sentiment])
          @selected_sentiment = params[:sentiment].to_f
        elsif @sentiment_phrase_map.has_key? params[:sentiment]
          @selected_sentiment = @sentiment_phrase_map[params[:sentiment]][1]
        end
      end


      #### DETERMINE THE POLICY_OR_LAW IF AVAILABLE #####
      if @selected_sentiment.present?        
        @options_policy_or_law = Letter.where(          
          sentiment: @selected_sentiment
        ).where(
	  "category LIKE lower(?)", "%#{@selected_category}%"
        ).pluck(:policy_or_law, :id)

        if params.has_key? :policy_or_law
          if is_number? params[:policy_or_law]
            @selected_policy_or_law = params[:policy_or_law].to_i
          else
            @selected_policy_or_law = []+Letter.where(
              sentiment: @selected_sentiment
            ).where(
	      "category LIKE lower(?)", "%#{@selected_category}%"
            ).where(
              "policy_or_law LIKE lower(?)", "%#{params[:policy_or_law]}%"
            ).pluck(:id)
            
          end
        end
      end
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

    def calculate_order_amount(item, count)

      if not count.present? or not item.present?
        return 0
      end
      
      if ['Priority Mail'].include? item
        return 500 * count
      elsif ['Letter', 'Letters'].include? item
        return 300 * count
      elsif ['Fax', 'Faxes'].include? item
        return 200 * count
      elsif ['Email', 'Emails'].include? item
        return 100 * count 
      end
    end

    def is_number? string
      true if Float(string) rescue false
    end
end
