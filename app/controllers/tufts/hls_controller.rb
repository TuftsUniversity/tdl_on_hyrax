# frozen_string_literal: true
# Tufts created controller for providing HLS files to mediaelement player.
module Tufts
  class HlsController < Hyrax::DownloadsController
    def show
      send_local_content
    rescue
      raise ActiveFedora::ObjectNotFoundError
    end

    private

      # Overwriting Hyrax::DownloadBehavior.load_file
      def load_file
        full_path = Hyrax::FileSetDerivativesService.new(file_set).derivative_url('m3u8')
        path_pieces = full_path.split('/')
        path_pieces[0] = '' # Remove file:/
        if params[:file] != 'm3u8'
          path_pieces[-1] = params[:file] # Replace p-m3u8.m3u8 file with .ts file, if supplied in request.
        end
        path_pieces.join('/')
      end

      def file_set
        @file_set ||= FileSet.find(params[:id])
      end
  end
end
