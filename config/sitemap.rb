# frozen_string_literal: true
require 'byebug'
SitemapGenerator::Sitemap.default_host = 'https://dl.tufts.edu'

SitemapGenerator::Sitemap.create do
  # We set a boolean value in our environment files to prevent generation in staging or development
  break unless Rails.application.config.sitemap[:generate]

  # Add static pages
  # This is quite primitive - could perhaps be improved by querying the Rails routes in the about namespace
  ['about'].each do |page|
    add "/#{page}", changefreq: 'yearly', priority: 0.9
  end

  # Add single record pages
  repo = CatalogController.new.repository
  response = repo.search('q': 'displays_in_sim:dl',
                         'qt': 'search',
                         'fq': ['displays_in_sim:dl',
                                '-suppressed_bsi:true',
                                '{!terms f=has_model_ssim}Audio,GenericObject,Image,Pdf,Rcr,Tei,Video,VotingRecord,Collection',
                                '({!terms f=edit_access_group_ssim}public) OR ' \
                                '({!terms f=discover_access_group_ssim}public) OR ' \
                                '({!terms f=read_access_group_ssim}public)',
                                '({!terms f=edit_access_group_ssim}public) OR ' \
                                '({!terms f=discover_access_group_ssim}public) OR ' \
                                '({!terms f=read_access_group_ssim}public)'],
                         'fl': 'id, has_model_ssim', # we only need the ids
                         #   'cursorMark' => cursor_mark, # we need to use the cursor mark to handle paging
                         'rows': ENV['BATCH_SIZE'] || 1_000_000,
                         'sort': 'system_create_dtsi asc')
  response['response']['docs'].each do |doc|
    # /concern/images/
    url = '/concern/'
    model = doc['has_model_ssim'].present? ? doc['has_model_ssim'].first : "SKIP"
    case  model
    when "Image"
      model = 'images/'
    when "Pdf"
      model = 'pdfs/'
    when "Rcr"
      model = 'rcrs/'
    when "Audio"
      model = 'audios/'
    when "Video"
      model = 'videos/'
    when "GenericObject"
      model = 'generic_objects/'
    when "Tei"
      model = 'teis/'
    when "VotingRecord"
      model = 'voting_records/'
    else
      next
    end
    add url + model + (doc['id']).to_s, changefreq: 'yearly', priority: 0.9
  end
end
