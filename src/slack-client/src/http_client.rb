# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# Basic HTTP client
class HttpClient
  def initialize(base_url, headers: {})
    @base_url = base_url
    @default_headers = headers
  end

  def get(path, params = {})
    uri = compose_uri(path, params)

    request = Net::HTTP::Get.new(uri)
    response = make_request(request)
    JSON.parse(response.body)
  end

  def post(path, params = {})
    uri = compose_uri(path)

    request = Net::HTTP::Post.new(uri)
    request.set_form_data(params)
    response = make_request(request)
    JSON.parse(response.body)
  end

  private

  def add_default_headers(req)
    req['Accept'] = 'application/json; charset=utf-8'
    req['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
    @default_headers.each do |name, value|
      req[name] = value
    end
  end

  def make_request(request)
    add_default_headers(request)
    http = Net::HTTP.new(request.uri.host, request.uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.request(request)
  end

  def compose_uri(path, params = {})
    URI("#{@base_url}/#{path}?#{URI.encode_www_form(params)}")
  end
end
