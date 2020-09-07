require 'sinatra'
require 'base64'
require 'json'

require_relative "../../app/helpers/event_manager"

class SnowBotDevApp < Sinatra::Base

	def initialize
		puts "Starting up web app."
		super()
	end

	#Load authentication details
	keys = {}
	set :dm_api_consumer_secret,'vxm2q6bw06xQKXxm4E7tWnaTDiuEU73QD2rib4BwXx5KvnmnID' #Account Activity API with OAuth

	set :title, 'snowbotdev'

	def generate_crc_response(consumer_secret, crc_token)
		hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
		return Base64.encode64(hash).strip!
	end

	get '/' do #TODO: future project to build the snowbot main page.
		'<p><b>Welcome to snowbotdev, home of the @SnowBotDev system...</b></p>
     <p>I am a sinatra-based web app...</p>
     <p>I consume Twitter Account Activity webhook events and manage DM bot dialogs...</p>
     <p>I serve a local hive of snow photos, snow reports, snow research links... </p>
     <p></p>
     <p><a href="https://github.com/twitterdev/SnowBotDev/wiki">Project tutorial and code</a></p>
     <p>#ThinkSnow...</p>'
	end

	# Receives challenge response check (CRC).
	get '/snowbotdev' do
		crc_token = params['crc_token']

		if not crc_token.nil?

			#puts "CRC event with #{crc_token}"
			#puts "headers: #{headers}"
			#puts headers['X-Twitter-Webhooks-Signature']

			response = {}
			response['response_token'] = "sha256=#{generate_crc_response(settings.dm_api_consumer_secret, crc_token)}"

			body response.to_json
		end

		status 200

	end

	# Receives DM events.
	post '/snowbotdev' do
		#puts "Received event(s) from DM API"
		request.body.rewind
		events = request.body.read

		manager = EventManager.new
		manager.handle_event(events)

		status 200
	end
end
