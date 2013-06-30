module Billable
  extend ActiveSupport::Concern

  included do
    rolify

    field :customer_id, type: String
    field :last_4_digits, type: String

    attr_accessible :stripe_token, :coupon, :name
    attr_accessor   :stripe_token, :coupon, :name
    before_create  :set_trialling_mode
    before_save    :update_subscription
    before_destroy :cancel_subscription    
  end

  module ClassMethods
  end

  def set_trialling_mode
    self.role_ids = []
    self.add_role :trialling # default   
  end

  def in_free_trial?
    has_role? :trialling
  end

  def premium?
    !in_free_trial?  
  end

  def update_plan(role_name)
    remove_role :trialling if has_role? :trialling
    add_role(role_name)
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id,"#{ENV["STRIPE_API_KEY"]}")
      customer.update_subscription(:plan => role.name)
    end
    true
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to update your subscription. #{e.message}."
    false
  end
  
  def need_to_update_stripe?
    (customer_id.nil? && stripe_token.present?) || customer_id.present?
  end

  def get_or_create_stripe_customer
    if customer_id.present?
      customer = Stripe::Customer.retrieve(customer_id,"#{ENV["STRIPE_API_KEY"]}")
      customer.card = stripe_token if stripe_token.present?
      customer.email = email
      customer.description = name
      customer.save
    elsif customer_id.nil? && stripe_token.present?
      if coupon.blank?
        customer = Stripe::Customer.create(
          {:email => email, :description => name, :card => stripe_token, :plan => roles.first.name },
          "#{ENV["STRIPE_API_KEY"]}"
        )
      else
        logger.info "Creating new stripe customer for #{self._id}"
        customer = Stripe::Customer.create(
          {:email => email,:description => name,:card => stripe_token,:plan => roles.first.name,:coupon => coupon},
          "#{ENV["STRIPE_API_KEY"]}"
        )
      end
    end
    customer
  end

  def update_subscription
    return unless need_to_update_stripe?
    logger.info "Updating #{self._id} subcription"

    customer = get_or_create_stripe_customer

    self.last_4_digits = customer.active_card.last4
    self.customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end
  
  def cancel_subscription
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id,"#{ENV["STRIPE_API_KEY"]}")
      unless customer.nil? or customer.respond_to?('deleted')
        if customer.subscription.status == 'active'
          customer.cancel_subscription
        end
      end
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end
  
  def expire
    UserMailer.expire_email(self).deliver
    destroy
  end

end
