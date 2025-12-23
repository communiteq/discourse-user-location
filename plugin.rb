# name: discourse-user-location
# about: Displays user registration and current location on user card and profile.
# version: 1.0
# authors: Communiteq B.V.
# url: https://github.com/communiteq/discourse-user-location

enabled_site_setting :user_location_enabled

register_asset 'stylesheets/common.scss'

after_initialize do
  User.register_custom_field_type 'user_location_data', :json

  module ::DiscourseUserLocation
    def self.resolve_country(ip)
      return nil if ip.blank?

      info = DiscourseIpInfo.get(ip)
      info[:country] if info
    end

    def self.get_or_update_location(user)
      data = user.custom_fields['user_location_data'] || {}
      data = {} unless data.is_a?(Hash)

      changed = false

      # Check Registration
      reg_ip = user.registration_ip_address.to_s
      if reg_ip.present?
        cached_reg = data['registered']
        if cached_reg.nil? || !cached_reg.key?(reg_ip)
          country = resolve_country(reg_ip)
          if country
            data['registered'] = { reg_ip => country }
            changed = true
          end
        end
      end

      # Check Current/Login
      current_ip = user.ip_address.to_s
      if current_ip.present?
        cached_login = data['login']
        if cached_login.nil? || !cached_login.key?(current_ip)
          country = resolve_country(current_ip)
          if country
            data['login'] = { current_ip => country }
            changed = true
          end
        end
      end

      if changed
        user.custom_fields['user_location_data'] = data
        user.save_custom_fields
      end

      # Return safe data for client (no IPs)
      {
        registered: data.dig('registered', reg_ip),
        current: data.dig('login', current_ip)
      }
    end
  end

  # Expose fields to the UserSerializer (for profile)
  add_to_serializer(:user, :user_location) do
    return unless SiteSetting.user_location_enabled
    DiscourseUserLocation.get_or_update_location(object)
  end

  # Expose fields to the UserCardSerializer (for user card)
  add_to_serializer(:user_card, :user_location) do
    return unless SiteSetting.user_location_enabled
    DiscourseUserLocation.get_or_update_location(object)
  end
end
