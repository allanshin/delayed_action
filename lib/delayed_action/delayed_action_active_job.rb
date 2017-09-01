class DelayedActionActiveJob < ActiveJob::Base

  queue_as :default

  def perform(result)

    begin
      # TODO: remove this hack
      Rack::Timeout.timeout = 0
    rescue

    end

    env = JSON.parse(result.request_env)
    session = ActionDispatch::Integration::Session.new(Rails.application)
    if env["QUERY_STRING"]
      env["QUERY_STRING"] = "force=true&#{env["QUERY_STRING"]}"
      path = "#{env["PATH_INFO"]}?force=true&#{env["QUERY_STRING"]}"
    else
      path = "#{env["PATH_INFO"]}?force=true"
    end
    puts path
    session.get path, nil, env
    result.update(result: session.response.body, content_type: session.response.content_type.to_s)

  end

end
