require 'jwt'
require 'openssl'

class GenAuth
  def self.run
    client_token = read_client_token
    client_key = read_client_key

    validate_client_key!(client_key, client_token)

    payload = {
      iat: Time.now.to_i + ENV['NOMIS_API_IAT_FUDGE_FACTOR'].to_i,
      token: client_token
    }

    "Bearer #{JWT.encode(payload, client_key, 'ES256')}"
  end

  protected
  
  def self.read_client_token
    token_filename = ENV['NOMIS_API_CLIENT_TOKEN_FILE']
    File.open(token_filename, 'r').read.chomp('')
  end

  def self.read_client_key
    client_keyfile = ENV['NOMIS_API_CLIENT_KEY_FILE']
    OpenSSL::PKey::EC.new(File.open(client_keyfile, 'r').read)
  end

  def self.validate_client_key!(client_key, client_token)
    expected_client_pub = JWT.decode(client_token, nil, nil)[0]["key"]

    unless client_pub_base64(client_key) == expected_client_pub
      puts "Incorrect private key supplied (does not match public key within token)"
      exit 1
    end
  end

  def self.client_pub_base64(client_key)
    client_pub = OpenSSL::PKey::EC.new client_key
    client_pub.private_key = nil
    Base64.strict_encode64(client_pub.to_der)
  end
end
