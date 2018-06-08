module PidMethods
  def self.ingested?(pid)
    result = false
    f4_id = ""
    thumbnail_path = ""
    model = ""

    fq = (pid.start_with?("tufts:") ? ('legacy_pid_tesim:"' + pid + '"') : ('id:"' + pid + '"'))

    solr_connection = ActiveFedora.solr.conn

    response = solr_connection.get 'select', params: { fq: fq, rows: '1' }
    collection_length = response['response']['docs'].length

    if collection_length > 0
      result = true
      resp_doc = response['response']['docs'][0]
      resp_id = resp_doc['id']
      resp_thumbnail_path = resp_doc['thumbnail_path_ss']
      resp_model = resp_doc['has_model_ssim']
      f4_id = resp_id unless resp_id.nil?
      thumbnail_path = resp_thumbnail_path unless resp_thumbnail_path.nil?
      model = resp_model.first unless resp_model.nil? || resp_model.empty?
    end

    [result, f4_id, thumbnail_path, model]
  end
end
