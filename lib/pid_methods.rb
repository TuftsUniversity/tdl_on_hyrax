# frozen_string_literal: true
module PidMethods
  def self.ingested?(pid)
    result = false
    f4_id = ""
    thumbnail_path = ""
    model = ""

    solr_connection = ActiveFedora.solr.conn
    response = solr_connection.get 'select', params: { fq: build_fq(pid), rows: '1' }
    collection_length = response['response']['docs'].length

    if collection_length.positive?
      result = true
      resp_doc = response['response']['docs'][0]
      resp_id = resp_doc['id']
      resp_thumbnail_path = resp_doc['thumbnail_path_ss']
      resp_model = resp_doc['has_model_ssim']
      f4_id = resp_id unless resp_id.nil?
      thumbnail_path = resp_thumbnail_path unless resp_thumbnail_path.nil?
      model = resp_model.first if resp_model.present?
    end

    [result, f4_id, thumbnail_path, model]
  end

  def self.urn_to_f3_pid(urn)
    return urn if f3_pid?(urn)
    index_of_colon = urn.rindex(':')
    pid = "tufts" + urn[index_of_colon, urn.length]
    pid
  end

  def self.f3_pid?(pid)
    # if this is a urn say no, otherwise say yes
    # unless pid.
    !pid.include? 'central'
  end

  def self.build_fq(pid)
    if pid.start_with?("tufts:")
      'legacy_pid_tesim:"' + pid + '"'
    elsif pid.include?("hdl.handle.net/10427/")
      'identifier_tesim:"' + pid + '"'
    else
      'id:"' + pid + '"'
    end
  end
end
