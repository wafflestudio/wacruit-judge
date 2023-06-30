require 'aws-sdk-secretsmanager'

def set_aws_managed_secrets
  # log message if not development or production and return
  unless %w[development production].include?(ENV['RAILS_ENV'])
    puts 'RAILS_ENV is not development or production'
    return
  end

  # secret name created in aws secret manager
  secret_name = ENV['RAILS_ENV'] == 'production' ? 'prod/wacruit' : 'dev/wacruit'
  
  # region name
  region_name = 'ap-northeast-2'

  client = Aws::SecretsManager::Client.new(region: region_name)

  begin
    get_secret_value_response = client.get_secret_value(secret_id: secret_name)
  rescue Aws::SecretsManager::Errors::ServiceError => e
    puts "Unable to fetch secrets from AWS: #{e.message}"
    return
  end

  if get_secret_value_response.secret_string
    puts get_secret_value_response.secret_string
    secret_hash = JSON.parse(get_secret_value_response.secret_string)
    ENV['DB_HOST'] = secret_hash['judge_db_host']
    ENV['DB_NAME'] = secret_hash['judge_db_name']
    ENV['DB_USERNAME'] = secret_hash['judge_db_username']
    ENV['DB_PORT'] = secret_hash['judge_db_port']
    ENV['DB_PASSWORD'] = secret_hash['judge_db_password']
  end
end

set_aws_managed_secrets