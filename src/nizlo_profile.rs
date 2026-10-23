// Nizlo's public rendezvous identity. This is a public verification key, never an access password.
const RENDEZVOUS_HOST: &str = "remote.nizlo.com";
const RENDEZVOUS_KEY: &str = "9dDi7PPaU0exoey3KXqhbilNmOYiZOLOlGBRBATJDwA=";

pub fn apply() {
    use hbb_common::config::{APP_NAME, OVERWRITE_SETTINGS, PROD_RENDEZVOUS_SERVER};

    *APP_NAME.write().unwrap() = "NizloRemote".to_owned();
    #[cfg(target_os = "macos")]
    {
        *hbb_common::config::ORG.write().unwrap() = "com.nizlo".to_owned();
    }
    *PROD_RENDEZVOUS_SERVER.write().unwrap() = RENDEZVOUS_HOST.to_owned();
    let mut settings = OVERWRITE_SETTINGS.write().unwrap();
    settings.insert("custom-rendezvous-server".to_owned(), RENDEZVOUS_HOST.to_owned());
    settings.insert("relay-server".to_owned(), RENDEZVOUS_HOST.to_owned());
    settings.insert("key".to_owned(), RENDEZVOUS_KEY.to_owned());
}
