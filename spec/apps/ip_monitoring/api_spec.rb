# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../apps/api'

describe IpMonitoring::API, db: true do
  include Rack::Test::Methods

  def app
    IpMonitoring::API
  end

  describe 'POST /ips' do
    subject(:request) { post '/ips', params.to_json, 'CONTENT_TYPE' => 'application/json' }

    context 'with valid params' do
      let(:params) { { ip: '8.8.8.8', enable: true } }

      it 'succeeds' do
        request

        expect(last_response.status).to eq(201)
      end

      it 'returns ip id' do
        request

        json_body = JSON.parse(last_response.body)
        expect(json_body).to have_key('id')
      end
    end

    context 'with ipv6 version' do
      let(:params) { { ip: '2a00:1450:4001:82b::200e', enable: true } }

      it 'succeeds' do
        request

        expect(last_response.status).to eq(201)
      end
    end

    context 'with invalid params' do
      let(:params) { { ip: '8.8.8', enable: true } }

      it 'returns bad_request status' do
        request

        expect(last_response.status).to eq(400)
      end
    end
  end

  describe 'POST /ips/:id/enable' do
    subject(:request) { post "/ips/#{ip_address.id}/enable" }

    context 'with existing ip' do
      let(:ip_address) { Factory[:ip_address] }

      it 'succeeds' do
        request

        expect(last_response.status).to eq(200)
      end
    end

    context 'with non-existent ip' do
      subject(:request) { post '/ips/1/enable' }

      it 'returns not_found status' do
        request

        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'POST /ips/:id/disable' do
    subject(:request) { post "/ips/#{ip_address.id}/disable" }

    context 'with existing ip' do
      let(:ip_address) { Factory[:ip_address] }

      it 'succeeds' do
        request

        expect(last_response.status).to eq(200)
      end
    end

    context 'with non-existent ip' do
      subject(:request) { post '/ips/1/disable' }

      it 'returns not_found status' do
        request

        expect(last_response.status).to eq(404)
      end
    end
  end

  describe 'GET /ips/:id/stats' do
    subject(:request) { get "/ips/#{ip_address.id}/stats", params }

    let(:params) do
      {
        time_from: DateTime.new(2023, 1, 1).strftime('%Y-%m-%dT%H:%M:%S.%6NZ'),
        time_to: DateTime.new(2023, 1, 2).strftime('%Y-%m-%dT%H:%M:%S.%6NZ')
      }
    end

    let(:ip_address) { Factory[:ip_address] }

    it 'succeeds' do
      request

      expect(last_response.status).to eq(200)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'returns empty stat' do
      request

      json_body = JSON.parse(last_response.body)
      expect(json_body).to include(
        'avg_rtt' => nil,
        'min_rtt' => nil,
        'max_rtt' => nil,
        'median_rtt' => nil,
        'stddev_rtt' => nil
      )
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe 'DELETE /ips/:id' do
    subject(:request) { delete "/ips/#{ip_address.id}" }

    let(:ip_address) { Factory[:ip_address] }

    it 'succeeds' do
      request

      expect(last_response.status).to eq(200)
    end
  end
end
