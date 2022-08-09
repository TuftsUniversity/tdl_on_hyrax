# frozen_string_literal: true
require 'active-fedora'

ActiveFedora::SolrService.instance_eval do
  def self.query(query, args = {})
    unless args.key?(:rows)
      # rubocop:disable Layout/LineLength
      Rails.logger.warn "Calling ActiveFedora::SolrService.get without passing an explicit value for ':rows' is not recommended. You will end up with Solr's default (usually set to 10)\nCalled by #{caller[0]}"
      # rubocop:enable Layout/LineLength
    end
    method = args.delete(:method) || default_http_method
    if method == :get
      result = get(query, args)
    elsif method == :post
      result = post(query, args)
    end
    result['response']['docs'].map do |doc|
      ActiveFedora::SolrHit.new(doc)
    end
  end

  def self.post(query, args = {})
    args = args.merge(q: query, qt: 'standard')
    ActiveFedora::SolrService.instance.conn.post(select_path, data: args)
  end

  def self.default_http_method
    ActiveFedora.solr_config.fetch(:http_method, :post).to_sym
  end
end
