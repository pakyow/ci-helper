# frozen_string_literal: true

require "json"
require "fileutils"

require "pakyow/ci/remote/server"

module Pakyow
  module CI
    module Remote
      # Interacts with a remote system.
      #
      class System
        # Create an ephemeral droplet, which is yielded when created and automatically destroyed.
        #
        def self.ephemeral(name:, ssh_public_key: "./id_rsa.pub", provider: "gcp", image: nil)
          FileUtils.mkdir_p "./tmp"

          ENV["TF_VAR_source_image"] = image unless image.nil?
          ENV["TF_VAR_instance_name"] = name
          ENV["TF_VAR_ssh_public_key"] = ssh_public_key

          unless system "terraform init -input=false ./providers/#{provider}/instance"
            fail "could not init"
          end

          unless system "terraform plan -out=./tmp/#{name}-instance.tfplan -input=false ./providers/#{provider}/instance >> /dev/null 2>&1"
            fail "could not plan"
          end

          unless system "terraform apply -input=false -state=./tmp/#{name}-instance.tfstate ./tmp/#{name}-instance.tfplan"
            fail "could not apply"
          end

          attributes = JSON.parse(File.read("./tmp/#{name}-instance.tfstate"))["resources"][0]["instances"][0]["attributes"]
          yield Server.new(attributes: attributes, provider: provider)
        ensure
          if system "terraform destroy -auto-approve -state=./tmp/#{name}-instance.tfstate"
            FileUtils.rm_f "tmp/#{name}-instance.tfstate"
            FileUtils.rm_f "tmp/#{name}-instance.tfstate.backup"
            FileUtils.rm_f "tmp/#{name}-instance.tfplan"
          end
        end
      end
    end
  end
end
