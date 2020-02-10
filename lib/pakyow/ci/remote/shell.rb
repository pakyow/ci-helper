# frozen_string_literal: true

require "net/scp"
require "net/ssh"

module Pakyow
  module CI
    module Remote
      # Provides a remote shell to run commands on a `Remote::Server` instance.
      #
      class Shell
        def initialize(server, user: "root", keys:)
          @server, @user, @keys = server, user, keys
        end

        # Yields `self` once the remote shell is available.
        #
        def when_available
          yield wait_until_available
        end

        # Run a command, returning the exit code.
        #
        def run(*command_parts, quiet: false)
          command_string = command_parts.join(" ")

          exit_code = nil
          ssh.open_channel { |channel|
            unless quiet
              puts "\n********************************************************************************"
              puts "ssh: #{command_string}"
            end

            channel.exec command_string do |command, success|
              raise "could not execute command: #{command_string}" unless success

              command.on_data do |_, data|
                unless quiet
                  $stdout.print data
                end
              end

              command.on_extended_data do |_, _type, data|
                unless quiet
                  $stderr.print data
                end
              end

              command.on_request "exit-status" do |_, data|
                exit_code = data.read_long
              end
            end

            unless quiet
              puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
            end
          }.wait

          exit_code
        end

        def upload(path)
          Net::SCP.upload!(
            @server.address, "root", path, "/root",
            ssh: {
              key_data: @keys,
              verify_host_key: :never,
              keepalive: true,
              keepalive_interval: 15
            },
            recursive: true
          )
        end

        private

        def wait_until_available(started_at = Time.now)
          if Time.now - started_at > 60
            fail "could not connect via ssh after 60s (server: #{@server.name})"
          else
            ssh; self
          end
        rescue Net::SSH::ConnectionTimeout, Net::SSH::AuthenticationFailed, Errno::ECONNREFUSED => error
          sleep 5 unless error.is_a?(Net::SSH::ConnectionTimeout)
          puts "waiting for shell (server: #{@server.name}, error: #{error})"
          retry
        end

        def ssh
          @ssh ||= Net::SSH.start(@server.address, @user, key_data: @keys, timeout: 5, verify_host_key: :never)
        end
      end
    end
  end
end
