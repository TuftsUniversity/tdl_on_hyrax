module Tufts
  class HlsController < Hyrax::DownloadsController
    def show
      return '' if params[:file].empty?

      if(params[:file] == 'm3u8')
        byebug
        super
      else
        return ''
      end
    end

    def path_to_derivs(find_m3u8 = false)
      full_path = Hyrax::FileSetDerivativesService.new(file_set).derivative_url('m3u8')
      if(find_m3u8)
        full_path
      else
        path_pieces = full_path.split('/')
        path_pieces.shift
        path_pieces.pop
        path_pieces.join('/')
      end
    end

    def file_set
      @file_set ||= FileSet.find(params[:id])
    end
  end
end