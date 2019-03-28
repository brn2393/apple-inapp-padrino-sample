##
# This file mounts each app in the Padrino project to a specified sub-uri.

##
# Setup global project settings for your apps. These settings are inherited by every subapp. You can
# override these settings in the subapps as needed.
#
Padrino.configure_apps do
  # enable :sessions
  set :session_secret, 'cff01d660908b6f9f8829b0916f1b7b593aec7d71211a90992f584bfaba55f2e'
  set :protection, except: :path_traversal
  set :protect_from_csrf, true
  set :allow_disabled_csrf, true
end

# Mounts the core application for this project
Padrino.mount('AppleInappSample::App', app_file: Padrino.root('app/app.rb')).to('/')
