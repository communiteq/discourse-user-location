require 'rails_helper'

describe 'DiscourseUserLocation' do
  before(:all) do
    require_relative '../../lib/discourse_user_location'
  end

  let(:user) { Fabricate(:user, ip_address: '1.2.3.4', registration_ip_address: '5.6.7.8') }

  before do
    SiteSetting.user_location_enabled = true
    DiscourseIpInfo.stubs(:get).with('1.2.3.4').returns({ country: 'US' })
    DiscourseIpInfo.stubs(:get).with('5.6.7.8').returns({ country: 'CA' })
  end

  describe '.resolve_country' do
    it 'returns the country code for a given IP' do
      expect(DiscourseUserLocation.resolve_country('1.2.3.4')).to eq('US')
    end

    it 'returns nil for blank IP' do
      expect(DiscourseUserLocation.resolve_country(nil)).to be_nil
    end

    it 'returns nil if IP info is missing' do
      DiscourseIpInfo.stubs(:get).with('9.9.9.9').returns(nil)
      expect(DiscourseUserLocation.resolve_country('9.9.9.9')).to be_nil
    end
  end

  describe '.is_exempt?' do
    let(:group) { Fabricate(:group) }

    it 'returns false if no exempt groups are configured' do
      SiteSetting.user_location_exempt_groups = ""
      expect(DiscourseUserLocation.is_exempt?(user)).to eq(false)
    end

    it 'returns false if user is not in any exempt group' do
      SiteSetting.user_location_exempt_groups = group.id.to_s
      expect(DiscourseUserLocation.is_exempt?(user)).to eq(false)
    end

    it 'returns true if user is in an exempt group' do
      SiteSetting.user_location_exempt_groups = group.id.to_s
      group.add(user)
      expect(DiscourseUserLocation.is_exempt?(user)).to eq(true)
    end
  end

  describe '.get_or_update_location' do
    it 'returns empty hash if user has no location data and IPs are missing' do
      user.update!(ip_address: nil, registration_ip_address: nil)
      expect(DiscourseUserLocation.get_or_update_location(user)).to eq({ registered: nil, current: nil })
    end

    it 'resolves and stores location data if missing' do
      result = DiscourseUserLocation.get_or_update_location(user)
      
      expect(result[:registered]).to eq('CA')
      expect(result[:current]).to eq('US')

      user.reload
      data = user.custom_fields['user_location_data']
      expect(data['registered']['5.6.7.8']).to eq('CA')
      expect(data['login']['1.2.3.4']).to eq('US')
    end

    it 'uses cached data if IP matches' do
      user.custom_fields['user_location_data'] = {
        'registered' => { '5.6.7.8' => 'FR' },
        'login' => { '1.2.3.4' => 'DE' }
      }
      user.save_custom_fields

      # Stub to ensure we don't call resolve_country (though stubs above would return US/CA)
      # We expect FR/DE from cache
      result = DiscourseUserLocation.get_or_update_location(user)
      
      expect(result[:registered]).to eq('FR')
      expect(result[:current]).to eq('DE')
    end

    it 'updates cache if IP changes' do
      user.custom_fields['user_location_data'] = {
        'login' => { '9.9.9.9' => 'DE' }
      }
      user.save_custom_fields

      result = DiscourseUserLocation.get_or_update_location(user)
      
      expect(result[:current]).to eq('US') # New IP 1.2.3.4 resolves to US

      user.reload
      data = user.custom_fields['user_location_data']
      expect(data['login']['1.2.3.4']).to eq('US')
    end
  end
end
