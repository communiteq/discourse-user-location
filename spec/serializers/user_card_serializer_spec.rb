require 'rails_helper'

describe UserCardSerializer do
  let(:user) { Fabricate(:user, ip_address: '1.2.3.4') }
  let(:serializer) { described_class.new(user, scope: Guardian.new) }

  before do
    SiteSetting.user_location_enabled = true
    DiscourseIpInfo.stubs(:get).with('1.2.3.4').returns({ country: 'US' })
  end

  it 'includes user_location when enabled' do
    json = serializer.as_json
    expect(json[:user_card][:user_location]).to be_present
    expect(json[:user_card][:user_location][:current]).to eq('US')
  end

  it 'does not include user_location when disabled' do
    SiteSetting.user_location_enabled = false
    json = serializer.as_json
    expect(json[:user_card]).not_to have_key(:user_location)
  end
end
