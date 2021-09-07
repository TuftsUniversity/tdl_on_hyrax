module Tufts
  class ContactFormController < Hyrax::ContactFormController
    private

    def build_contact_form
      @contact_form = Tufts::ContactForm.new(contact_form_params)
    end
  end
end