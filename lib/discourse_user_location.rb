module ::DiscourseUserLocation
  def self.resolve_country(ip)
    return nil if ip.blank?

    info = DiscourseIpInfo.get(ip)
    info[:country] if info
  end

  def self.is_exempt?(user)
    return false if SiteSetting.user_location_exempt_groups.blank?
    exempt_group_ids = SiteSetting.user_location_exempt_groups.split('|')
    user.groups.where(id: exempt_group_ids).exists?
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
