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
    uri = URI("#{@base_url}/#{path}?#{URI.encode_www_form(params)}")

    request = Net::HTTP::Get.new(uri)
    add_default_headers(request)

    response = make_request(uri, request)
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

  def make_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.request(request)
  end
end
