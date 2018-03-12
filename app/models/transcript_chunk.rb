class TranscriptChunk
  # this class is used to hold state about transcript fragments, typically from a TEI file
  # it includes code to parse the TEI file's participants and transcript elements

  # each TranscriptChunk has an id, a start time and a list of utterances
  # each Utterance has text and perhaps the speaker's initials/short name
  # all the chunks for a transcript are typically stored in an array
  # a class variable holds metadata about speakers
  #  note that tei files might have no metadata for some speakers

  # should we create an object for the entire transcript and move the parse and speaker code there

  # TEI has speaker data, parse_participants stores data in @@speakers
  @@speakers = []

  def self.get_speakers
    @@speakers
  end

  # instance variable for each transcript chunk
  attr_reader :name
  attr_reader :start_in_milliseconds
  attr_reader :utterances

  def initialize(chunk_name, start_in_milliseconds)
    @name = chunk_name
    @start_in_milliseconds = start_in_milliseconds
    @utterances = []
  end

  # parse passed tei object and return an array of TranscriptChunk objects
  def self.parse(om_document)
    parse_participants(om_document)
    result = parse_transcript(om_document)
    [result, @@speakers]
  end

  # parse tei participant element and store in class variable
  def self.parse_participants(om_document)
    @@speakers = []

    node_sets = om_document.find_by_terms(:participants)
    node_sets.each do |node|
      node.children.each do |child|
        next if child.attributes.empty?
        initials = child.attributes['id']
        initials = initials.nil? ? '' : initials.value
        role = child.attributes['role']
        role = role.nil? ? '' : role.value
        gender = child.attributes['sex'].to_s
        name = child.text
        participant = TranscriptChunk.add_speaker(name, initials, role, gender)
      end
    end
  end

  # parse transcript and return an array of TranscriptChunk objects
  #   each of chunk holds an array of TranscriptChunk.Utterances
  # for utterances without a speaker, we try to use the last speaker
  def self.parse_transcript(om_document)
    result = []
    # first we get all the timestamps elements:
    #   <when id="timepoint_12" since="timepoint_begin" interval="813400"/>
    # and create a hashtable where the ids are
    #  timestamp names (e.g., timepoint_12)
    #  and the values are time in milliseconds since the start (e.g., 813400)
    timepoints = {}
    node_sets = om_document.find_by_terms_and_value(:when)

    node_sets.each do |node|
      timepoint_id = node.attributes["id"]
      timepoint_interval = node.attributes["interval"]
      next if timepoint_id.nil? || timepoint_interval.nil?
      timepoint_id = timepoint_id.value
      timepoint_interval = timepoint_interval.value
      timepoints[timepoint_id] = timepoint_interval
    end

    # now we get all the transcript fragments, each has a start attribute that should
    # match up with a timestamp id discovered above:
    #   <u rend="transcript_chunk" start="timepoint_12" n="12" end="timepoint_13">
    # create TruanscriptChunk instances to hold data
    node_sets = om_document.find_by_terms_and_value(:u)

    node_sets.each do |node|
      string_total_seconds = ""
      timepoint_id = node.attributes["start"]
      next if timepoint_id.nil?
      timepoint_id = timepoint_id.value
      timepoint_interval = timepoints[timepoint_id]
      next if timepoint_interval.nil?
      # timepoint_interval is a String containing the timestamp in milliseconds
      string_milliseconds = timepoint_interval
      int_milliseconds = string_milliseconds.to_i
      # create new object to hold this chunk
      current_transcript_chunk = TranscriptChunk.new(timepoint_id, int_milliseconds)
      result << current_transcript_chunk
      # actual text and speaker is held in child nodes
      # <u who="RK">well thank you it&#8217;s really a great privilege and honour ....</u>
      # loop over children adding utterances
      node.children.each do |child|
        childName = child.name
        if childName == "u"
          whoNode = child.attributes["who"]
          speaker = if whoNode
                      TranscriptChunk.get_speaker(whoNode.value)
                    else
                      get_last_speaker(result)
                    end
          who = TranscriptChunk.get_speaker_initials(speaker)
          text = parse_notations(child)
          current_transcript_chunk.add_utterance(text, who, timepoint_id)
        elsif childName == "event" || childName == "gap" || childName == "vocal" || childName == "kinesic"
          unless child.attributes.empty?
            desc = child.attributes["desc"]
            unless desc.nil?
              current_transcript_chunk.add_utterance(desc, nil, timepoint_id)
            end
          end
        end
      end
    end
    result
  end

  # loop over all chunks backwards to identify the last speaker
  def self.get_last_speaker(chunks)
    chunks.reverse_each do |chunk|
      last_speaker = chunk.get_last_speaker_from_chunk
      return last_speaker unless last_speaker.nil?
    end
    nil
  end

  # add an utterance to this transcript chunk
  def add_utterance(text, speaker_initials = '', timepoint_id)
    utterance = Utterance.new(text, speaker_initials, timepoint_id)
    @utterances << utterance
  end

  # loop over utterances backwards looking for the last speaker
  # @return speaker object if available or speaker initials/id if not
  def get_last_speaker_from_chunk
    return nil if @utterances.empty?
    @utterances.reverse_each do |current_utterance|
      next if current_utterance.speaker_initials.nil? || current_utterance.speaker_initials.empty?
      speaker_initials = current_utterance.speaker_initials
      speaker = TranscriptChunk.get_speaker(speaker_initials)
      return speaker.nil? ? speaker_initials : speaker
    end
    nil
  end

  # accepts speaker object or speaker initials, returns initials
  # note that not all speakers in the transcript are listed in the participant metadata
  def self.get_speaker_initials(speaker)
    return '' if speaker.nil?
    return speaker if speaker.is_a? String
    speaker.initials
  end

  # return a string with all the text from all of this chunk's utterances
  # this is useful to obtain a string for ingesting into Solr
  # @return a string containing the text from all the utterances
  def get_text
    result = ''
    @utterances.each do |utterance|
      unless result.empty?
        result << ' ' # add space separator between utterances
      end
      result << utterance.text
    end
    result
  end

  # add speaker to class variable list if they are not already on the list
  def self.add_speaker(name, initials, role, gender)
    speaker = get_speaker(initials)
    if speaker.nil?
      speaker = Speaker.new(name, initials, role, gender)
      @@speakers << speaker
    end
    speaker
  end

  # look up speaker by passed initials
  def self.get_speaker(initials)
    @@speakers.each do |speaker|
      return speaker if speaker.initials == initials
    end
    nil
  end

  # hold state for a single utterance from a transcript
  class Utterance
    attr_accessor :text
    attr_reader :speaker_initials
    attr_reader :timepoint_id

    def initialize(text, speaker_initials = nil, timepoint_id)
      @text = text
      @speaker_initials = speaker_initials
      @timepoint_id = timepoint_id
    end
  end

  # metadata about speakers is stored in Speaker objects
  class Speaker
    attr_reader :name
    attr_reader :initials
    attr_reader :gender
    attr_reader :role

    def initialize(name, initials, role, gender)
      @name = name
      @initials = initials
      @role = role
      @gender = gender
    end
  end

  # this mark-up code doesn't belong here
  # is it worth the trouble to add state to here and do the markup elsewhere
  def self.parse_notations(node)
    result = ''

    node.children.each do |child|
      childName = child.name

      if childName == "text"
        result += child.text
      elsif childName == "unclear"
        result += "<span class=\"transcript_notation\">[" + child.text + "]</span>"
      elsif childName == "event" || childName == "gap" || childName == "vocal" || childName == "kinesic"
        unless child.attributes.empty?
          desc = child.attributes["desc"]
          unless desc.nil?
            result += "<span class=\"transcript_notation\">[" + desc + "]</span>"
          end
        end
      end
    end

    result
  end
end
