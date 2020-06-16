require 'sinatra'
require 'haml'
require 'rest-client'
require 'json'

set :public_folder, File.dirname(__FILE__) + '/views'
#TODO: Read from YMAL
caddy_server = 'http://10.0.0.110:2019/'

def humanize_caddy_types(caddy_type)
  case caddy_type
  when 'reverse_proxy'
    return 'Reverse Proxy'
  end
end

def get_caddy_servers
  #TODO: Read from YAML
  caddy_config = JSON.parse(RestClient.get 'http://10.0.0.110:2019/config/')
  servers = {}
  domains = []

  caddy_config['apps']['http']['servers'].each do |key, value|
    servers[key] = value['listen'][0] == ':443' ? 'https://' : 'http://'
  end

  servers.each do |key, value|
    server_key = key
    i = 0
    caddy_config['apps']['http']['servers'][server_key]['routes'].each do |key, value|
      domains << {
        :host => key['handle'][0]['routes'][0]['handle'][0]['upstreams'][0]['dial'],
        :type => humanize_caddy_types(key['handle'][0]['routes'][0]['handle'][0]['handler']),
        :domain => servers[server_key] + key['match'][0]['host'][0],
        :server_key => server_key,
        :route_index => i
      }
      i += 1
    end
  end

  return domains
end

get '/' do
  haml :index, :locals => {:domains => get_caddy_servers, :caddy_server => caddy_server}
end

get '/export' do
  pretty_json = JSON.pretty_generate(JSON.parse(RestClient.get 'http://10.0.0.110:2019/config/'))
  haml :export, :locals => {:json_config => pretty_json}
end

delete '/api/delete/:server/:route' do
  url = "http://10.0.0.110:2019/config/apps/http/servers/#{params[:server]}/routes/#{params[:route]}"
  response = RestClient.delete url
  return {:status => response.code}.to_json
end