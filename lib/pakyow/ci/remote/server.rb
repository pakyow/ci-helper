# frozen_string_literal: true

require "droplet_kit"

require "pakyow/ci/remote/shell"

module Pakyow
  module CI
    module Remote
      # Wraps a DigitalOcean droplet.
      #
      class Server
        def initialize(droplet, client: nil, digital_ocean_key: ENV["DIGITAL_OCEAN_KEY"])
          @droplet = droplet
          @client = client || DropletKit::Client.new(access_token: digital_ocean_key)
        end

        # Unique identifier of the server.
        #
        def id
          @droplet.id
        end

        # Public ip address of the server.
        #
        def address
          @droplet.networks[0][0].ip_address
        end

        # Yields a `Remote::Shell` instance ready for running commands.
        #
        def shell(**options, &block)
          Shell.new(self, **options).when_available(&block)
        end

        # Create a snapshot of the server.
        #
        def snapshot!(name = @droplet.name)
          @client.droplet_actions.snapshot(droplet_id: @droplet.id, name: name)
        end
      end
    end
  end
end
