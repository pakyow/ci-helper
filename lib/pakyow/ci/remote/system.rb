# frozen_string_literal: true

require "droplet_kit"

require "pakyow/ci/remote/server"

module Pakyow
  module CI
    module Remote
      # Wraps a DigitalOcean client.
      #
      class System
        def initialize(digital_ocean_key: ENV["DIGITAL_OCEAN_KEY"])
          @client = DropletKit::Client.new(access_token: digital_ocean_key)
        end

        # Create an ephemeral droplet, which is yielded when created and automatically destroyed.
        #
        def ephemeral(name:, region: "sfo2", image: "ubuntu-18-04-x64", size: "s-1vcpu-1gb", ssh_keys: [])
          droplet = @client.droplets.create(
            DropletKit::Droplet.new(
              name: name,
              region: region,
              image: image,
              size: size,
              ssh_keys: ssh_keys
            )
          )

          yield Server.new(wait_for_droplet(droplet), client: @client)
        ensure
          @client.droplets.delete(id: droplet&.id)
        end

        private

        def wait_for_droplet(droplet)
          until droplet.status == "active"
            puts "waiting for #{droplet.id} (status: #{droplet.status})"
            sleep 5; droplet = @client.droplets.find(id: droplet.id)
          end

          droplet
        end
      end
    end
  end
end
