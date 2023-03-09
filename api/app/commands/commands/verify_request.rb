class Commands::VerifyRequest
  VERSION = "v0"
  SIGNING_SECRET = ENV["SLACK_SIGNING_SECRET"]

  def self.run(...)
    new(...).run
  end

  attr_reader :timestamp, :body, :expected_signature
  def initialize(request)
    # puts request.headers.to_h
    @timestamp = request.get_header('HTTP_X_SLACK_REQUEST_TIMESTAMP').to_i
    @expected_signature = request.get_header('HTTP_X_SLACK_SIGNATURE')
    @body = begin
      body = request.body.read
      request.body.rewind
      body
    end
  end

  def run
    return false if expired?
    return false unless expected_signature.present?

    digest = [
      VERSION,
      OpenSSL::HMAC.hexdigest('sha256', SIGNING_SECRET, data)
    ].join('=')

    return false unless digest.length == expected_signature.length

    return OpenSSL.fixed_length_secure_compare(digest, expected_signature)
  end

  def data
    [VERSION, timestamp, body].join(':')
  end

  def expired?
    return false unless Rails.env.production?
    return true if Time.at(timestamp) < 5.minutes.ago
  end
end
