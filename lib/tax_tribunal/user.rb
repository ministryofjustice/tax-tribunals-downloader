require_relative 's3'

module TaxTribunal
  class User
    extend TaxTribunal::S3
    USERS_DIR = 'users'

    def self.find(uuid)
      return nil if uuid.nil? || uuid.empty?
      if user_obj(uuid).exists?
        data = JSON.parse(user_obj(uuid).get.body.read, symbolize_names: true)
        OpenStruct.new(
          id: uuid,
          email: data.fetch(:email),
          profile: data.fetch(:profile),
          logout: data.fetch(:logout)
        )
      end
    end

    def self.create(uuid, opts)
      user_obj(uuid).put(
        body: {
          email: opts.fetch(:email),
          profile: opts.fetch(:profile),
          logout: opts.fetch(:logout)
        }.to_json
      )
    end

    def self.user_obj(uuid)
      bucket.object([USERS_DIR, uuid].join('/'))
    end

    def self.bucket_name
      ENV.fetch('USER_BUCKET_NAME')
    end
  end
end
