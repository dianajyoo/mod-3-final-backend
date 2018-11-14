require("ibm_watson/tone_analyzer_v3")
require("json")

class TextInputsController < ApplicationController

  # GET /text_inputs
  def index
    @text_inputs = TextInput.all

    # tone_analyzer = IBMWatson::ToneAnalyzerV3.new(
    #   iam_apikey: ENV['IBMWATSON_API_KEY'],
    #   version: "2017-09-21"
    # )
    #
    # @result = tone_analyzer.tone(
    #   tone_input: strong_params["text"],
    #   content_type: "text/plain"
    # ).result
    # # byebug
    #
    render json: @text_inputs
  end

  # GET /text_inputs/:id
  def show
    render json: @text_inputs
  end

  def create
    tone_analyzer = IBMWatson::ToneAnalyzerV3.new(
      iam_apikey: ENV['IBMWATSON_API_KEY'],
      version: "2017-09-21"
    )

    @result = tone_analyzer.tone(
      tone_input: strong_params["text"],
      content_type: "text/plain"
    ).result

    # @result = {"document_tone"=>{"tones"=>[{"score"=>0.725456,
    #   "tone_id"=>"joy", "tone_name"=>"Joy"}, {"score"=>0.842108, "tone_id"=>"analytical", "tone_name"=>"Analytical"}]}}

    @document_tone = @result["document_tone"]["tones"]

    @document_tone.each do |tone|
      if tone.key?('score')
        @score = tone['score'] * 100
      end

      if tone['tone_name'] != nil || tone['tone_name'] != []
        @tone = tone['tone_name']
      else
        @score = 100
        @tone = 'Neutral'
      end

      @analysis = {text: strong_params['text'], score: @score, tone: @tone}
      @textInput = TextInput.create(@analysis)

    end

    render json: @result

  end

  private

  def strong_params
    params.require(:text_input).permit(:text, :score, :tone)
  end

end
