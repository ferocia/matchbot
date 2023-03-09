class SlackController < ApplicationController
  before_action :verify!

  def event
    case params[:type]
    when "url_verification"
      url_verification
    when "event_callback"
      event_callback
    else
      head :bad_request
    end
  end

  def slash
    render json: Commands::SlackSlash.run(params[:channel_id], params[:text])
  end

  private

  def url_verification
    render plain: params[:challenge]
  end

  def event_callback
    Commands::EventCallback.run(params.require(:event))
  end

  def verify!
    return if Commands::VerifyRequest.run(request)

    head :unauthorized
  end
end
