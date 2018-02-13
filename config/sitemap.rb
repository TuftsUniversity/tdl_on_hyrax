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
  cursor_mark = '*'
  repo = CatalogController.new.repository
  loop do
    response = repo.search('q' => 'displays_in_sim:dl',
                           'qt' => 'search',
                           'fq' => ['displays_in_sim:dl', '-suppressed_bsi:true', '{!terms f=has_model_ssim}Audio,Ead,GenericObject,Image,Pdf,Rcr,Tei,Video,VotingRecord,Collection', '({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)', '({!terms f=edit_access_group_ssim}public) OR ({!terms f=discover_access_group_ssim}public) OR ({!terms f=read_access_group_ssim}public)'],
                           'fl'         => 'id', # we only need the ids
                           'cursorMark' => cursor_mark, # we need to use the cursor mark to handle paging
                           'rows'       => ENV['BATCH_SIZE'] || 1_000_000,
                           'sort'       => 'id asc')

    response['response']['docs'].each do |doc|
      add "/catalog/#{doc['id']}", changefreq: 'yearly', priority: 0.9
    end

    break if response['nextCursorMark'] == cursor_mark # this means the result set is finished

    cursor_mark = response['nextCursorMark']
  end
end
