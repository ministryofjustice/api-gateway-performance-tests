require 'jwt'
require 'openssl'

class GenAuth
  def self.run
    token_filename = ENV['NOMIS_API_CLIENT_TOKEN_FILE']
    client_token = File.open(token_filename, 'r').read.chomp('')

    client_keyfile = ENV['NOMIS_API_CLIENT_KEY_FILE']
    client_key = OpenSSL::PKey::EC.new(File.open(client_keyfile, 'r').read)

    client_pub = OpenSSL::PKey::EC.new client_key
    client_pub.private_key = nil
    client_pub_base64 = Base64.strict_encode64(client_pub.to_der)

    expected_client_pub = JWT.decode(client_token, nil, nil)[0]["key"]

    unless client_pub_base64 == expected_client_pub
      puts "Incorrect private key supplied (does not match public key within token)"
      exit 1
    end

    payload = {
      iat: Time.now.to_i,
      token: client_token
    }

    "Bearer #{JWT.encode(payload, client_key, 'ES256')}"
  end
end
