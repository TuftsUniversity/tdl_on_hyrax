# frozen_string_literal: true
FactoryBot.define do
  factory :tufts_MS123_audio, class: Audio do
    transient do
      user { FactoryBot.create(:user) } # find_or_create ???
    end
    id { '1234jt5bg' }
    title { ['Interview with Horace Works'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    description { ['Interview conducted by Kenneth J. Cleary.'] }

    before(:create) do |work, evaluator|
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['Fileset for audio'], id: '1234jt5fs')
      work.ordered_members << create(:file_set, user: evaluator.user, title: ['Fileset for transcript'], id: '1234jt5tr')
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    after(:create) do |work, _evaluator|
      work.file_sets.each do |file_set|
        case file_set.id
        when '1234jt5fs'
          # If this were an actual object created in Mira, this would be the archival .wav file,
          # instead of the .mp3, but the .wav is too big to commit to github and the code in
          # audio_presenter.rb only cares that it isn't text/xml.
          # For this to work there must also be a copy of the .mp3 at tmp/derivatives/12/34/jt/5a/u-mp3.mp3.
          audio_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'MS123.001.001.00002.mp3')))
          original_file = file_set.build_original_file
          original_file.mime_type = 'audio/mpeg'
          original_file.content = audio_test_file
          file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          file_set.save
        when '1234jt5tr'
          transcript_test_file = File.open(File.expand_path(Rails.root.join('spec', 'fixtures', 'MS123.001.001.00002.tei.xml')))
          original_file = file_set.build_original_file
          original_file.mime_type = 'text/xml'
          original_file.content = transcript_test_file
          file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          file_set.save
        end
      end

      work.save
    end
  end
end
