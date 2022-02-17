# frozen_string_literal: true

# Customizing the contact form to remove category field and make subject field optional.
require_dependency Hyrax::Engine.root.join('app', 'models', 'hyrax', 'contact_form').to_s
module Hyrax
  class ContactForm
    clear_validators!
    validates :email, :name, :message, presence: true
    validates :email, format: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true
  end
end
