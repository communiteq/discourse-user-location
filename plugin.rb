# name: discourse-user-location
# about: Displays user registration and current location on user card and profile.
# version: 1.0.1
# authors: Communiteq
# url: https://github.com/communiteq/discourse-user-location

enabled_site_setting :user_location_enabled

register_asset 'stylesheets/common.scss'

require_relative 'lib/discourse_user_location'

after_initialize do
  User.register_custom_field_type 'user_location_data', :json

  # Expose fields to the UserSerializer (for profile)
  add_to_serializer(:user, :user_location, include_condition: -> {
    SiteSetting.user_location_enabled && !DiscourseUserLocation.is_exempt?(object)
  }) do
    DiscourseUserLocation.get_or_update_location(object)
  end

  # Expose fields to the UserCardSerializer (for user card)
  add_to_serializer(:user_card, :user_location, include_condition: -> {
    SiteSetting.user_location_enabled && !DiscourseUserLocation.is_exempt?(object)
  }) do
    DiscourseUserLocation.get_or_update_location(object)
  end
end
