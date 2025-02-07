import 'package:expe_traking/data_domain/storage/auth_helper.dart';
import 'package:expe_traking/data_domain/utils/AppValues.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> fetchConfig() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(hours: 1),
      ),
    );

    // // Set default values
    // await _remoteConfig.setDefaults({
    //   AppValues.remote_config_Access_token_key : "", // Default integer value
    // });

    await _remoteConfig.fetchAndActivate();
    AuthHelper.saveNotificationToken(
        _remoteConfig.getString(AppValues.remote_config_Access_token_key));
    print(
        'Config fetched: ${_remoteConfig.getString(AppValues.remote_config_Access_token_key)}');
  }

  String getConfigValue(String key) {
    return _remoteConfig.getString(key);
  }
}
