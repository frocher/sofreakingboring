class Settings < Settingslogic
  source "#{Rails.root}/config/olb.yml"
  namespace Rails.env
 end


#
# Olb general settings
#
Settings.olb['https'] = false if Settings.olb['https'].nil?

#
# Gravatar
#
Settings['gravatar'] ||= Settingslogic.new({})
Settings.gravatar['enabled']      = true if Settings.gravatar['enabled'].nil?
Settings.gravatar['plain_url']  ||= 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
Settings.gravatar['ssl_url']    ||= 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'