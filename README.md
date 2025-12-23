# Discourse User Location

A Discourse plugin that displays a user's registration country and current location (based on IP) on their User Card and User Profile.

## Features

*   **Dual Location Display**: Shows where a user registered and where they are currently located.
*   **Privacy Focused**: IP addresses are resolved to countries on the server side. Only country names are sent to the client.
*   **Performance Optimized**: Location data is cached in User Custom Fields to minimize IP lookup overhead. Updates occur lazily when a user profile or card is viewed, and only if the IP has changed.
*   **Customizable**: Can be enabled or disabled via site settings.

## Installation

Follow the standard [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157) guide for Discourse.

1.  Add the plugin's repository URL to your container's `app.yml` file:

    ```yaml
    hooks:
      after_code:
        - exec:
            cd: $home/plugins
            cmd:
              - git clone https://github.com/communiteq/discourse-user-location.git
    ```

2.  Rebuild your container:

    ```bash
    ./launcher rebuild app
    ```

## Configuration

*   **user_location_enabled**: (Default: true) Enable or disable the display of user locations.

## Usage

Once installed and enabled, the plugin automatically works. When you view a user's card or profile, their location information will be displayed if available.

## License

MIT
