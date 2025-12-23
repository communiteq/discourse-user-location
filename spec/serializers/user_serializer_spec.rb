require 'rails_helper'

describe UserSerializer do
  let(:user) { Fabricate(:user, ip_address: '1.2.3.4') }
  let(:serializer) { described_class.new(user, scope: Guardian.new) }

  before do
    SiteSetting.user_location_enabled = true
    DiscourseIpInfo.stubs(:get).with('1.2.3.4').returns({ country: 'US' })
  end

  it 'includes user_location when enabled' do
    json = serializer.as_json
    expect(json[:user][:user_location]).to be_present
    expect(json[:user][:user_location][:current]).to eq('US')
  end

  it 'does not include user_location when disabled' do
    SiteSetting.user_location_enabled = false
    json = serializer.as_json
    expect(json[:user]).not_to have_key(:user_location)
  end

  it 'does not include user_location when user is exempt' do
    group = Fabricate(:group)
    SiteSetting.user_location_exempt_groups = group.id.to_s
    group.add(user)
    
    json = serializer.as_json
    expect(json[:user]).not_to have_key(:user_location)
  end
end
