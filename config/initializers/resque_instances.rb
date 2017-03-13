if Rails.env.test?
  RESQUES = Resques.new([
    ResqueInstance.new(
      name: "localhost",
      resque_data_store: Resque::DataStore.new(Redis::Namespace.new(:resque,redis: Redis.new)),
      stale_worker_seconds: (ENV['RESQUE_BRAIN_STALE_WORKER_SECONDS'] || '3600').to_i
    )
  ])
elsif ENV['VCAP_SERVICES']
  RESQUES = Resques.new(
    CF::App::Service.new.send(:all).select { |s| s['name'] =~ /redis/ }.map do |service|
      creds = service['credentials']
      redis_url = "redis://user:#{creds['password']}@#{creds['host']}:#{creds['port']}"

      ResqueInstance.new(
        name: service['name'],
        resque_data_store: Resque::DataStore.new(Redis::Namespace.new(:resque, redis: Redis.new(url: redis_url))),
        stale_worker_seconds: (ENV['RESQUE_BRAIN_STALE_WORKER_SECONDS'] || '3600').to_i
      )
    end
  )
else
  RESQUES = Resques.from_environment
end
