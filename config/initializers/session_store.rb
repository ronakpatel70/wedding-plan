# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: 'we_session', expire_after: 30.days, secure: Rails.env.production?
