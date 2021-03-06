require 'shipitron'
require 'shipitron/find_docker_volume_name'

module Shipitron
  class S3Copy
    include Metaractor

    required :source
    required :destination
    required :region

    def call
      if ENV['FOG_LOCAL']
        Logger.info `cp #{source.gsub('s3://', '/fog/')} #{destination.gsub('s3://', '/fog/')}`
        if $? != 0
          fail_with_error!(message: 'Failed to transfer to/from s3 (mocked).')
        end
      else
        Logger.info "S3 Copy from #{source} to #{destination}"

        shipitron_home_volume = FindDockerVolumeName.call!(
          container_name: 'shipitron',
          volume_search: /shipitron-home/
        ).volume_name

        Logger.info `docker run --rm -t -v #{shipitron_home_volume}:/home/shipitron -e AWS_CONTAINER_CREDENTIALS_RELATIVE_URI amazon/aws-cli:latest --region #{region} s3 cp #{source} #{destination} --quiet --only-show-errors`
        if $? != 0
          fail_with_error!(message: 'Failed to transfer to/from s3.')
        end
      end
    end

    private
    def source
      context.source
    end

    def destination
      context.destination
    end

    def region
      context.region
    end
  end
end
