class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:make_call]
  def index
  end

  def make_call
    response = Twilio::TwiML::VoiceResponse.new
    response.dial(number: '+15863290488')
    render xml: response.to_s
  end

  def create
    if params[:forward_to].present?
      provision_phone_number
      flash[:notice] = "Number provisioned, your number is #{@number}"
    else
      flash[:notice] = "You must provide a phone number"
    end
    redirect_to root_url
  end

  def release_number
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    trial_number = TrialNumber.find(params[:trial_id])
    @client.incoming_phone_numbers(trial_number.sid).delete
    trial_number.delete
    flash[:notice] = "number has been released"
    redirect_to root_url
  end

  def provision_phone_number

    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    begin
      # Lookup numbers in host area code, if none than lookup from anywhere
      @numbers = @client.api.available_phone_numbers('US').local.list(area_code: 415)
      if @numbers.empty?
        @numbers = @client.api.available_phone_numbers('US').local.list()
      end

      # Purchase the number & set the application_sid for voice and sms, will
      # tell the number where to route calls/sms
      @number = @numbers.first.phone_number
      response = @client.api.incoming_phone_numbers.create(
        phone_number: @number,
        voice_method: 'post',
        voice_url: make_call_url
      )
      TrialNumber.create(
        mask_number: @number,
        forward_to_number: params[:forward_to],
        sid: response.sid
      )
    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
  end
end
