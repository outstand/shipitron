require 'shipitron'
require 'shellwords'
require 'shipitron/git_info'

module Shipitron
  module Server
    module Git
      class Clone
        include Metaractor

        required :application
        required :repository_url
        optional :repository_branch

        before do
          context.repository_branch ||= 'main'
        end

        def call
          Logger.info "Using this branch: #{repository_branch}"
          FileUtils.cd('/home/shipitron') do
            `git clone #{Shellwords.escape repository_url} --recursive --branch #{Shellwords.escape repository_branch} #{Shellwords.escape application}`
          end

          Logger.info 'Using this git commit:'
          context.git_info = GitInfo.from_path(path: "/home/shipitron/#{application}")
          Logger.info context.git_info.one_liner
        end

        private
        def application
          context.application
        end

        def repository_url
          context.repository_url
        end

        def repository_branch
          context.repository_branch
        end
      end
    end
  end
end
