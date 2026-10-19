# Production: set FRONTEND_ORIGINS to the deployed frontend URL(s), comma-separated
# (e.g. https://filmmint.vercel.app). Development also allows any localhost port, because
# Vite moves to the next free port (5173, 5174, ...) when one is taken.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    configured = ENV.fetch("FRONTEND_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)
    local = Rails.env.production? ? [] : [ %r{\Ahttp://(localhost|127\.0\.0\.1):\d+\z} ]
    origins(*configured, *local)
    resource "*", headers: :any, methods: %i[get post put patch delete options head]
  end
end
