class Settings < Settingslogic
  source File.join(Sinatra::Application.root, 'config', 'settings.yml').to_s
  namespace Sinatra::Application.environment.to_s
end
