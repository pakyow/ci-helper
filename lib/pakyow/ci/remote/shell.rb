# frozen_string_literal: true

require "net/scp"
require "net/ssh"

module Pakyow
  module CI
    module Remote
      # Provides a remote shell to run commands on a `Remote::Server` instance.
      #
      class Shell
        def initialize(server, user: "root", keys: ["~/.ssh/id_rsa"])
          @server, @user, @keys = server, user, keys
        end

        # Yields `self` once the remote shell is available.
        #
        def when_available
          yield wait_until_available
        end

        # Run a command, returning the exit code.
        #
        def run(*command_parts)
          command_string = command_parts.join(" ")

          exit_code = nil
          ssh.open_channel { |channel|
            puts "\n********************************************************************************"
            puts "ssh: #{command_string}"

            channel.exec command_string do |command, success|
              raise "could not execute command: #{command_string}" unless success

              command.on_data do |_, data|
                $stdout.print data
              end

              command.on_extended_data do |_, _type, data|
                $stderr.print data
              end

              # TODO: Need this?
              # command.on_close do; end

              command.on_request "exit-status" do |_, data|
                exit_code = data.read_long
              end
            end

            puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
          }.wait

          exit_code
        end

        private

        def wait_until_available
          ssh; self
        rescue Net::SSH::ConnectionTimeout, Errno::ECONNREFUSED => error
          sleep 5 unless error.is_a?(Net::SSH::ConnectionTimeout)
          puts "waiting for shell (server: #{@server.id}, error: #{error})"
          retry
        end

        def ssh
          @ssh ||= Net::SSH.start(@server.address, @user, keys: @keys, timeout: 5)
        end
      end
    end
  end
end
