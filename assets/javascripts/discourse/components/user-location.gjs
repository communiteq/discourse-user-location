import Component from "@glimmer/component";
import icon from "discourse-common/helpers/d-icon";
import I18n from "discourse-i18n";

export default class UserLocation extends Component {
  get locationText() {
    const locationData = this.args?.user?.user_location || this.args?.model?.user_location;
    if (!locationData) {
      return null;
    }

    const registered = locationData.registered;
    const current = locationData.current;
    const parts = [];

    if (registered) {
      parts.push(I18n.t("user_location.registered", { country: registered }));
    }

    if (current) {
      parts.push(I18n.t("user_location.current", { country: current }));
    }

    if (parts.length === 0) {
      return null;
    }

    return parts.join(" · ");
  }

  <template>
    {{#if this.locationText}}
      <div class="user-location">
        {{icon 'globe'}}
        <span>{{this.locationText}}</span>
      </div>
    {{/if}}
  </template>
}
