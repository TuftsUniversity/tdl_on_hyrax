# frozen_string_literal: true
module Tufts
  class ContactForm < Hyrax::ContactForm
    attr_accessor :contact_method, :name, :email, :message, :subject
    validates :email, :name, :message, presence: true
  end
end
