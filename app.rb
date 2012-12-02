# -*- encoding: utf-8 -*-
require 'sinatra/base'
require "sinatra/reloader"
require 'json'
require 'active_record'

class App < Sinatra::Base
	ActiveRecord::Base.configurations = YAML.load_file( File.dirname(__FILE__) + '/config/database.yml')
	configure :development do
		ActiveRecord::Base.establish_connection('development')
		register Sinatra::Reloader
	end
	
	configure :test do
		ActiveRecord::Base.establish_connection('test')
	end
	
	configure :production do
		ActiveRecord::Base.establish_connection('production')
	end
	
	( Dir::glob(File.dirname(__FILE__) + "/models/*.rb") ).sort.each do |model|
		require model
	end
	
	before do
		content_type :json
		@not_found_error = {:errorcode=>404,:message=>'page not found'}
	end
	
	# チャンネル一覧
	get '/channel/list' do
		channel= Channel.all
		channel.to_json
	end
	
	# チャンネルID
	get '/channel/:cid' do
		channel= Channel.find_by_id(params[:cid])
		unless channel then
			return {:errorcode=>500,:message=>'request channel not exists'}.to_json
		end

		channel.to_json
	end
	
	# チャンネルグループ一覧
	get '/channelgroup/list' do
		channelgroup= ChannelGroup.all
		channelgroup.to_json
	end
	
	# チャンネルグループID
	get '/channelgroup/:cgid' do
		channelgroup= ChannelGroup.find_by_id(params[:cgid])
		unless channelgroup then
			return {:errorcode=>500,:message=>'request channelgroup not exists'}.to_json
		end

		channelgroup.to_json
	end
	
	not_found do
	  @not_found_error.to_json
	end
end
