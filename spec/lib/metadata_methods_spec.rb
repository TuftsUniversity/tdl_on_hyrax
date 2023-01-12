# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MetadataMethods do
  describe 'find_closest_white_space_index' do
    let(:text) do
      'This study sought to determine some of the attitudes, values, and '\
      'perceptions of Animal Control Officers ("ACOs") in Massachusetts with '\
      'respect to wildlife generally and human-coyote conflicts specifically. '\
      'The study incorporated a qualitative interpretative analysis based upon '\
      'the data collected from personal in-depth interviews conducted with ACOs '\
      'who were randomly selected from several counties throughout Massachusetts.'
    end
    it 'returns start index if there are no spaces' do
      result = described_class.find_closest_white_space_index('test', 3)
      expect(result).to eq(3)
    end

    it 'finds the space on the start index' do
      result = described_class.find_closest_white_space_index(text, 10)
      expect(result).to eq(10)
    end

    it 'finds white space to the left of the start postition' do
      result = described_class.find_closest_white_space_index(text, 11)
      expect(result).to eq(10)
    end

    it 'finds white space to the right of the start postition' do
      result = described_class.find_closest_white_space_index(text, 9)
      expect(result).to eq(10)
    end

    it 'finds white space that are enters' do
      result = described_class.find_closest_white_space_index('test' + "\n" + 'longwords', 10)
      expect(result).to eq(4)
    end

    it 'finds white space to the left even if there is none to the right' do
      result = described_class.find_closest_white_space_index(text, text.length - 1)
      expect(result).to eq(411)
    end

    it 'finds white space to the right even if there is none to the left' do
      result = described_class.find_closest_white_space_index(text, 0)
      expect(result).to eq(4)
    end
  end
end
