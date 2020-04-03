module ApplicationHelper
	def render_thumbnail_by_type(document, image_options = {}, url_options = {})
		type = document['has_model_ssim']

		value = if (type - ['Rcr']).empty?
			# override
			url = '/assets/rcr/rcr.png'
	    	image_tag url, image_options if url.present?
	    elsif (type - ['Ead']).empty?
	    	url = '/assets/ead/file_box.png'
	    	image_tag url, image_options if url.present?
		elsif (type - ['VotingRecord']).empty?
	    	url = '/assets/datasets/datasets.png'
	    	image_tag url, image_options if url.present?	    	
	    elsif (type - ['GenericObject']).empty?
	    	url = '/assets/generic/generic.png'
	    	image_tag url, image_options if url.present?	    		
		elsif blacklight_config.view_config(document_index_view_type).thumbnail_field
      	  url = thumbnail_url(document)
      	  image_tag url, image_options if url.present?
    	end

	    if value
    	  if url_options == false
        	Deprecation.warn(self, "passing false as the second argument to render_thumbnail_tag is deprecated. Use suppress_link: true instead. This behavior will be removed in Blacklight 7")
        	url_options = { suppress_link: true }
      	  end
      	
      	  if url_options[:suppress_link]
            value
          else
            link_to_document document, value, url_options
      	  end    
      	end
	end
end
