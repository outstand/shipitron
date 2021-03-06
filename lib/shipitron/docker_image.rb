require 'shipitron'

module Shipitron
  class DockerImage < Hashie::Dash
    property :registry
    property :name
    property :tag

    def name_with_tag(tag_override = nil)
      tag_str = [tag_override, tag, ''].find {|str| !str.nil? }
      tag_str = tag_str.to_s

      if !tag_str.empty? && !tag_str.start_with?(':')
        tag_str = tag_str.dup.prepend(':')
      end

      name_with_registry = [registry, name].compact.join('/')

      "#{name_with_registry}#{tag_str}"
    end

    def to_s
      name_with_tag
    end
  end
end
