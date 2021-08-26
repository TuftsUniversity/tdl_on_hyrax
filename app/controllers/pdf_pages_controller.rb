# frozen_string_literal: true
class PdfPagesController < ApplicationController
  CONFIG = YAML.load_file(Rails.root.join('config', 'pdf_pages.yml'))[Rails.env]

  def initialize
    @pages_root = CONFIG['pages_root']
  end

  def dimensions
    file_set = FileSet.find(params[:id])
    if file_set.nil?
      logger.warn("No such file asset: " + params[:id])
      flash[:retrieval] = "No such file asset."
      redirect_to(action: 'index', q: nil, f: nil)
    else
      # get containing object for this FileAsset
      ##      pid = @file_asset.container_id
      ##      @downloadable = false
      ##      # A FileAsset is downloadable iff the user has read or higher access to a parent
      ##      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      ##      if reader?
      ##        @downloadable = true
      ##      end

      # mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))
      # pdf_pages = Settings.pdfpages.pagelocation
      # file name format PB.002.001.00001-0.png
      # pid-pagenumber.png
      # /pdf_pages/data05/tufts/central/dca/PB/access_pdf_pageimages/PB.002.001.00001
      # /pdf_pages/data05/tufts/central/dca/PB/access_pdf_pageimages/PB.002.001.00001
      meta_path = File.join(@pages_root, file_set.id, 'book.json')

      send_file(meta_path)
    end
  end

  def show
    file_set = FileSet.find(params[:id])
    if file_set.nil?
      logger.warn("No such file asset: " + params[:id])
      flash[:retrieval] = "No such file asset."
      redirect_to(action: 'index', q: nil, f: nil)
    else
      ##      #if isUnderEmbargo || isMissingCommunityMemberRole
      ##    #    redirect_to(:root, :q => nil, :f => nil) and return false
      ##  #    end
      # get containing object for this FileAsset
      ##      pid = file_set.id
      ##      ##@downloadable = false
      # A FileAsset is downloadable iff the user has read or higher access to a parent
      ##      @response, @permissions_solr_document = get_solr_response_for_doc_id(pid)
      ##      if reader?
      ##        @downloadable = true
      ##      end

      # mapped_model_names = ModelNameHelper.map_model_names(@file_asset.relationships(:has_model))
      # pdf_pages = Settings.pdfpages.pagelocation
      # file name format PB.002.001.00001-0.png
      # pid-pagenumber.png
      # /pdf_pages/data05/tufts/central/dca/PB/access_pdf_pageimages/PB.002.001.00001
      ##      dsLocation = @file_asset.datastreams["Archival.pdf"].dsLocation
      ##      local_path = convert_url_to_png_path(dsLocation, params[:pageNumber], params[:id])
      page_number = params[:pageNumber]
      local_file = file_set.id + '_' + page_number.to_s + ".png"
      local_path = File.join(@pages_root, file_set.id, local_file)
      send_file(local_path)
    end
  end

  private

    def missing_community_member_role?
      return true if current_user.nil?
      false
    end

    def under_embargo?
      obj = ActiveFedora::Base.find(params[:id])
      return false if obj.embargo.nil?
      true
    end
end
