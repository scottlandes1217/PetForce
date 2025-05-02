Rails.application.config.after_initialize do
  Rails.application.reload_routes!
end 