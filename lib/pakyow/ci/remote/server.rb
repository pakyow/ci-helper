# frozen_string_literal: true

require "pakyow/ci/remote/shell"

module Pakyow
  module CI
    module Remote
      # A remote server.
      #
      class Server
        def initialize(attributes:, provider:)
          @attributes, @provider = attributes, provider
        end

        def name
          @attributes["name"]
        end

        def address
          @attributes["network_interface"][0]["access_config"][0]["nat_ip"]
        end

        # Yields a `Remote::Shell` instance ready for running commands.
        #
        def shell(**options, &block)
          Shell.new(self, **options).when_available(&block)
        end

        # Create an image of the server.
        #
        def image!(name: self.name, family:)
          FileUtils.mkdir_p "./tmp"

          ENV["TF_VAR_image_family"] = family
          ENV["TF_VAR_image_name"] = name
          ENV["TF_VAR_source_disk_url"] = @attributes["boot_disk"][0]["source"]

          unless system "terraform init -input=false ./providers/#{@provider}/image"
            fail "could not init"
          end

          unless system "terraform plan -out=./tmp/#{name}-image.tfplan -input=false ./providers/#{@provider}/image"
            fail "could not plan"
          end

          unless system "terraform apply -input=false -state=./tmp/#{name}-image.tfstate ./tmp/#{name}-image.tfplan"
            fail "could not apply"
          end
        ensure
          FileUtils.rm_f "tmp/#{name}-image.tfstate"
          FileUtils.rm_f "tmp/#{name}-image.tfstate.backup"
          FileUtils.rm_f "tmp/#{name}-image.tfplan"
        end
      end
    end
  end
end
