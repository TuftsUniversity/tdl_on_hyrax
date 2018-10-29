class GalleryController < ApplicationController
  def image_gallery
    @document_fedora = Tei.find(params[:id])

    #metadata = Tufts::ModelMethods.get_metadata(@document_fedora)
    title = @document_fedora.title.first
    #title = metadata[:titles].nil? ? "" : metadata[:titles].first
    xml = Nokogiri::XML(@document_fedora.file_sets.first.original_file.content)
    xml.remove_namespaces! unless xml.nil?
    node_sets = xml.xpath('//figure')
    total_length = node_sets.length

    figures = []

    start = Integer(params[:start])
    end_figure = Integer(params[:number])

    unless node_sets.nil?
      node_sets = node_sets.slice(start, end_figure)
      node_sets.each do |node|
        image_pid = PidMethods.urn_to_f3_pid(node[:n])
        image_title = ""
        full_title = ""
        @image = Image.where(legacy_pid_tesim: image_pid)

        @image = @image.first
        begin
          #image_metadata = Tufts::ModelMethods.get_metadata(@image)
          image_title = @image.title.first unless @image.title.nil? #image_metadata[:titles].nil? ? "" : image_metadata[:titles].first
          full_title = image_title
          image_title = image_title.slice(0, 17) + '...' if image_title.length > 20

        rescue NoMethodError
          image_title = ""
        end

        figures << { pid: @image.id, caption: image_title, full_title: full_title }
      end
    end

    render json: { figures: figures, count: total_length, title: "Illustrations from the " + title.to_s }
  end

  def image_overlay
    @document_fedora = TuftsBase.find(params[:id])
    metadata = Tufts::ModelMethods.get_metadata(@document_fedora)
    title = metadata[:titles].nil? ? "" : metadata[:titles].first
    temporal = if metadata[:temporals].nil?
                 ""
               else
                 metadata[:temporals].first.nil? ? "" : metadata[:temporals].first
               end
    description = if metadata[:descriptions].nil?
                    ""
                  else
                    metadata[:descriptions].first.nil? ? "" : metadata[:descriptions].first
                  end
    pid = params[:id]
    item_link = '/catalog/' + pid
    image_url = '/downloads/' + pid + '?file=thumbnail'

  #  logger.error(convert_url_to_local_path(@document_fedora.datastreams["Basic.jpg"].dsLocation))
    #imagesize = ImageSize.new File.open(convert_url_to_local_path(@document_fedora.datastreams["Basic.jpg"].dsLocation), "rb").read

    render json: { back_url: "#", item_title: title, item_date: temporal, image_url: image_url, item_link: item_link, item_description: description, width: imagesize.height, height: imagesize.width }
  end

  def dimensions
    @file_asset = TuftsBase.find(params[:id])

    if @file_asset.nil?
      logger.warn("No such file asset: " + params[:id])
      flash[:retrieval] = "No such file asset."
      redirect_to(action: 'index', q: nil, f: nil)
    else
      # get containing object for this TuftsBase
      # pid = @file_asset.container_id
      pid = params[:id]
      @downloadable = false
      # A TuftsBase is downloadable iff the user has read or higher access to a parent
      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      @downloadable = true if reader?

      redirect_to(:root, q: nil, f: nil) && (return false) if isUnderEmbargo || isMissingCommunityMemberRole
      mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))

      if mapped_model_names.include?("info:fedora/afmodel:TuftsImage")
        if @file_asset.datastreams.include?("Advanced.jpg")
          imagesize = ImageSize.new File.open(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation), "rb").read

          render json: { height: imagesize.height, width: imagesize.width }
        end
      end

      if mapped_model_names.include?("info:fedora/afmodel:TuftsImageText")
        if @file_asset.datastreams.include?("Advanced.jpg")
          imagesize = ImageSize.new File.open(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation), "rb").read
          render json: { height: imagesize.height, width: imagesize.width }
        end
      end

      if mapped_model_names.include?("info:fedora/afmodel:TuftsWP")
        if @file_asset.datastreams.include?("Basic.jpg")
          imagesize = ImageSize.new File.open(convert_url_to_local_path(@file_asset.datastreams["Advanced.jpg"].dsLocation), "rb").read
          render json: { height: imagesize.height, width: imagesize.width }.to_s
        end
      end
    end
  end
end
