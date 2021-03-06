module Braintree
  class CreditCard
    include BaseModule # :nodoc:
    include Braintree::Util::TokenEquality

    module CardType
      AmEx = "American Express"
      CarteBlanche = "Carte Blanche"
      ChinaUnionPay = "China UnionPay"
      DinersClubInternational = "Diners Club"
      Discover = "Discover"
      JCB = "JCB"
      Laser = "Laser"
      UK_Maestro = "UK Maestro"
      Maestro = "Maestro"
      MasterCard = "MasterCard"
      Solo = "Solo"
      Switch = "Switch"
      Visa = "Visa"
      Unknown = "Unknown"

      All = constants.map { |c| const_get(c) }
    end

    module CustomerLocation
      International = "international"
      US = "us"
    end

    module CardTypeIndicator
      Yes = "Yes"
      No = "No"
      Unknown = "Unknown"
    end

    Commercial = Debit = DurbinRegulated = Healthcare = Payroll = Prepaid = ProductId =
      IssuingBank = CountryOfIssuance = CardTypeIndicator

    attr_reader :billing_address
    attr_reader :bin
    attr_reader :card_type
    attr_reader :cardholder_name
    attr_reader :commercial
    attr_reader :country_of_issuance
    attr_reader :created_at
    attr_reader :customer_id
    attr_reader :debit
    attr_reader :durbin_regulated
    attr_reader :expiration_month
    attr_reader :expiration_year
    attr_reader :healthcare
    attr_reader :image_url
    attr_reader :issuing_bank
    attr_reader :last_4
    attr_reader :payroll
    attr_reader :prepaid
    attr_reader :product_id
    attr_reader :subscriptions
    attr_reader :token
    attr_reader :unique_number_identifier
    attr_reader :updated_at
    attr_reader :verification

    def self.create(attributes)
      Configuration.gateway.credit_card.create(attributes)
    end

    def self.create!(attributes)
      return_object_or_raise(:credit_card) { create(attributes) }
    end

    # Deprecated. Use Braintree::TransparentRedirect.url
    def self.create_credit_card_url
      warn "[DEPRECATED] CreditCard.create_credit_card_url is deprecated. Please use TransparentRedirect.url"
      Configuration.gateway.credit_card.create_credit_card_url
    end

    # Deprecated. Use Braintree::TransparentRedirect.confirm
    def self.create_from_transparent_redirect(query_string)
      warn "[DEPRECATED] CreditCard.create_from_transparent_redirect is deprecated. Please use TransparentRedirect.confirm"
      Configuration.gateway.credit_card.create_from_transparent_redirect(query_string)
    end

    def self.credit(token, transaction_attributes)
      Transaction.credit(transaction_attributes.merge(:payment_method_token => token))
    end

    def self.credit!(token, transaction_attributes)
      return_object_or_raise(:transaction) { credit(token, transaction_attributes) }
    end

    def self.delete(token)
      Configuration.gateway.credit_card.delete(token)
    end

    def self.expired(options = {})
      Configuration.gateway.credit_card.expired(options)
    end

    def self.expiring_between(start_date, end_date, options = {})
      Configuration.gateway.credit_card.expiring_between(start_date, end_date, options)
    end

    def self.find(token)
      Configuration.gateway.credit_card.find(token)
    end

    def self.from_nonce(nonce)
      Configuration.gateway.credit_card.from_nonce(nonce)
    end

    # Deprecated. Use Braintree::PaymentMethod.grant
    def self.grant(token, allow_vaulting)
      Configuration.gateway.credit_card.grant(token, allow_vaulting)
    end

    def self.sale(token, transaction_attributes)
      Configuration.gateway.transaction.sale(transaction_attributes.merge(:payment_method_token => token))
    end

    def self.sale!(token, transaction_attributes)
      return_object_or_raise(:transaction) { sale(token, transaction_attributes) }
    end

    def self.update(token, attributes)
      Configuration.gateway.credit_card.update(token, attributes)
    end

    def self.update!(token, attributes)
      return_object_or_raise(:credit_card) { update(token, attributes) }
    end

    # Deprecated. Use Braintree::TransparentRedirect.confirm
    def self.update_from_transparent_redirect(query_string)
      warn "[DEPRECATED] CreditCard.update_via_transparent_redirect_request is deprecated. Please use TransparentRedirect.confirm"
      Configuration.gateway.credit_card.update_from_transparent_redirect(query_string)
    end

    # Deprecated. Use Braintree::TransparentRedirect.url
    def self.update_credit_card_url
      warn "[DEPRECATED] CreditCard.update_credit_card_url is deprecated. Please use TransparentRedirect.url"
      Configuration.gateway.credit_card.update_credit_card_url
    end

    def initialize(gateway, attributes) # :nodoc:
      @gateway = gateway
      set_instance_variables_from_hash(attributes)
      @billing_address = attributes[:billing_address] ? Address._new(@gateway, attributes[:billing_address]) : nil
      @subscriptions = (@subscriptions || []).map { |subscription_hash| Subscription._new(@gateway, subscription_hash) }
      @verification = _most_recent_verification(attributes)
    end

    def _most_recent_verification(attributes)
      verification = (attributes[:verifications] || []).sort_by{ |verification| verification[:created_at] }.reverse.first
      CreditCardVerification._new(verification) if verification
    end

    # Deprecated. Use Braintree::CreditCard.credit
    def credit(transaction_attributes)
      warn "[DEPRECATED] credit as an instance method is deprecated. Please use CreditCard.credit"
      @gateway.transaction.credit(transaction_attributes.merge(:payment_method_token => token))
    end

    # Deprecated. Use Braintree::CreditCard.credit!
    def credit!(transaction_attributes)
      warn "[DEPRECATED] credit! as an instance method is deprecated. Please use CreditCard.credit!"
      return_object_or_raise(:transaction) { credit(transaction_attributes) }
    end

    # Deprecated. Use Braintree::CreditCard.delete
    def delete
      warn "[DEPRECATED] delete as an instance method is deprecated. Please use CreditCard.delete"
      @gateway.credit_card.delete(token)
    end

    # Returns true if this credit card is the customer's default payment method.
    def default?
      @default
    end

    # Expiration date formatted as MM/YYYY
    def expiration_date
      "#{expiration_month}/#{expiration_year}"
    end

    # Returns true if the credit card is expired.
    def expired?
      @expired
    end

    def inspect # :nodoc:
      first = [:token]
      order = first + (self.class._attributes - first)
      nice_attributes = order.map do |attr|
        "#{attr}: #{send(attr).inspect}"
      end
      "#<#{self.class} #{nice_attributes.join(', ')}>"
    end

    def masked_number
      "#{bin}******#{last_4}"
    end

    # Deprecated. Use Braintree::CreditCard.sale
    def sale(transaction_attributes)
      warn "[DEPRECATED] sale as an instance method is deprecated. Please use CreditCard.sale"
      @gateway.transaction.sale(transaction_attributes.merge(:payment_method_token => token))
    end

    # Deprecated. Use Braintree::CreditCard.sale!
    def sale!(transaction_attributes)
      warn "[DEPRECATED] sale! as an instance method is deprecated. Please use CreditCard.sale!"
      return_object_or_raise(:transaction) { sale(transaction_attributes) }
    end

    # Deprecated. Use Braintree::CreditCard.update
    def update(attributes)
      warn "[DEPRECATED] update as an instance method is deprecated. Please use CreditCard.update"
      result = @gateway.credit_card.update(token, attributes)
      if result.success?
        copy_instance_variables_from_object result.credit_card
      end
      result
    end

    # Deprecated. Use Braintree::CreditCard.update!
    def update!(attributes)
      warn "[DEPRECATED] update! as an instance method is deprecated. Please use CreditCard.update!"
      return_object_or_raise(:credit_card) { update(attributes) }
    end

    def nonce
      @nonce ||= PaymentMethodNonce.create(token)
    end

    # Returns true if the card is associated with Venmo SDK
    def venmo_sdk?
      @venmo_sdk
    end

    class << self
      protected :new
    end

    def self._attributes # :nodoc:
      [
        :billing_address, :bin, :card_type, :cardholder_name, :created_at, :customer_id, :expiration_month,
        :expiration_year, :last_4, :token, :updated_at, :prepaid, :payroll, :product_id, :commercial, :debit, :durbin_regulated,
        :healthcare, :country_of_issuance, :issuing_bank, :image_url
      ]
    end

    def self._new(*args) # :nodoc:
      self.new *args
    end
  end
end
