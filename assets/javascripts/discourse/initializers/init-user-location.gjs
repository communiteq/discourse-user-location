import { apiInitializer } from "discourse/lib/api";
import UserLocation from "../components/user-location";
export default apiInitializer((api) => {
  api.renderInOutlet("user-card-metadata", UserLocation);
  api.renderInOutlet("user-profile-primary", UserLocation);
});
