module TaxTribunal
  class User
    extend TaxTribunal::AzureBlobStorage
    USERS_DIR = 'users'

    def self.find(uuid)
      return nil if uuid.nil? || uuid.empty?

      unless (user = get_user(uuid)).nil?
        data = JSON.parse(user, symbolize_names: true)
        OpenStruct.new(
          id: uuid,
          email: data.fetch(:email),
          profile: data.fetch(:profile),
          logout: data.fetch(:logout)
        )
      end
    end

    def self.get_user(uuid)
      storage.get_blob(user_container_name, user_id(uuid)).last
    rescue
      nil
    end

    def self.create(uuid, opts)
      storage.create_block_blob(
        user_container_name,
        user_id(uuid),
        {
          email: opts.fetch(:email),
          profile: opts.fetch(:profile),
          logout: opts.fetch(:logout)
        }.to_json
      )
    end

    def self.user_id(uuid)
      [USERS_DIR, uuid].join('/')
    end
  end
end
