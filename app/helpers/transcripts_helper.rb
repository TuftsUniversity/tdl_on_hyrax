# frozen_string_literal: true
module TranscriptsHelper
  def self.format_participants(participants)
    result = ""
    participant_number = 0

    participants.each do |participant|
      participant_number += 1
      id = participant.initials
      role = participant.role
      sex = participant.gender
      name = participant.name
      result << "        <div class=\"participant_row\" id=\"participant" + participant_number.to_s + "\">\n"
      result << "          <div class=\"participant_id\">" + (id.nil? ? "" : id) + "</div>\n"
      result << "          <div class=\"participant_name\">" + name + "<span class=\"participant_role\">" +
                (role.nil? ? "" : ", " + role) +
                (sex.empty? ? "" : " (" + (sex == "f" ? "female" : (sex == "m" ? "male" : sex)) + ")") + "</span></div>\n"
      result << "        </div> <!-- participant_row -->\n"
    end

    result = "<div class=\"participant_table\">\n" + result + "      </div> <!-- participant_table -->\n" unless result.empty?

    result
  end

  # convert fedora transcript object to html
  def self.show_transcript(tei, active_timestamps, path)
    chunks, participants = TranscriptChunk.parse(tei)
    transcript_html = format_transcript(chunks, active_timestamps, path)
    participant_html = format_participants(participants)

    [transcript_html, participant_html]
  end

  def self.get_time_table(tei)
    chunks = TranscriptChunk.parse(tei)
    table = extract_time_table(chunks)

    table
  end

  def self.extract_time_table(chunks)
    table = {}
    chunks.each do |chunk|
      milliseconds = chunk.start_in_milliseconds
      string_minutes, string_just_seconds, _string_total_seconds = displayable_time(milliseconds)
      table[chunk.name.to_s] = { time: milliseconds, display_time: string_minutes + ":" + string_just_seconds }
    end

    table
  end

  # return html string of the transcript
  # iterate over chunks and create appropriate divs with classes, links, etc.
  def self.format_transcript(chunks, active_timestamps, path)
    result = "<div class=\"transcript_table\">\n"
    chunks.each do |chunk|
      milliseconds = chunk.start_in_milliseconds
      string_minutes, string_just_seconds, string_total_seconds = displayable_time(milliseconds)

      result << "                <div class=\"transcript_chunk\" id=\"chunk" + string_total_seconds + "\">\n"

      unless milliseconds.nil?
        result << "                  <div class=\"transcript_row\">\n"
        result << "                    <div class=\"transcript_speaker\">\n"

        result << if active_timestamps
                    "                      <a class=\"transcript_chunk_link\" data-time=\"#{milliseconds}\" " \
                    "href=\"#{path}?timestamp/#{string_minutes}:#{string_just_seconds}\">#{string_minutes}:#{string_just_seconds}</a>\n"
                  else
                    "                      <span class=\"transcript_chunk_link\">" + string_minutes + ":" + string_just_seconds + "</span>\n"
                  end

        result << "                    </div> <!-- transcript_speaker -->\n"
        result << "                    <div class=\"transcript_utterance\"></div>\n"
        result << "                  </div> <!-- transcript_row -->\n"
      end

      utterances = chunk.utterances
      utterances.each do |utterance|
        who = utterance.speaker_initials
        text = utterance.text
        timepoint_id = utterance.timepoint_id

        if who
          result << "                  <div class=\"transcript_row\">\n"
          result << "                    <div class=\"transcript_speaker\">" + (who.nil? ? "" : who) + "</div>\n"
          result << "                    <div class=\"transcript_utterance\"  id=\"" + timepoint_id + "\">" + (text.nil? ? "" : text) + "</div>\n"
          result << "                  </div> <!-- transcript_row -->\n"
        else
          unless text.nil?
            result << "                  <div class=\"transcript_row\">\n"
            result << "                    <div class=\"transcript_speaker\"></div>\n"
            result << "                    <div class=\"transcript_utterance\" id=\"" + timepoint_id + "\"><span class = \"transcript_notation\">[" + text + "]</span></div>\n"
            result << "                  </div> <!-- transcript_row -->\n"
          end
        end
      end

      result << "                </div> <!-- transcript_chunk -->\n"
    end

    result << "              </div> <!-- transcript_table -->\n"

    result
  end

  def self.parse_notations(node)
    result = ""

    node.children.each do |child|
      child_name = child.name

      if child_name == "text"
        result += child.text
      elsif child_name == "unclear"
        result += "<span class=\"transcript_notation\">[" + child.text + "]</span>"
      elsif child_name == "event" || child_name == "gap" || child_name == "vocal" || child_name == "kinesic"
        unless child.attributes.empty?
          desc = child.attributes["desc"]
          result += "<span class=\"transcript_notation\">[" + desc + "]</span>" unless desc.nil?
        end
      end
    end

    result
  end

  # convert a transcript time in milliseconds into displayable strings for UI
  def self.displayable_time(milliseconds)
    int_total_seconds = milliseconds.to_i / 1000 # truncated to the second
    int_minutes = int_total_seconds / 60
    int_just_seconds = int_total_seconds - (int_minutes * 60) # the seconds for seconds:minutes (0:00) display
    string_minutes = int_minutes.to_s
    string_just_seconds = int_just_seconds.to_s

    string_just_seconds = "0" + string_just_seconds if int_just_seconds < 10

    [string_minutes, string_just_seconds, int_total_seconds.to_s]
  end
end
