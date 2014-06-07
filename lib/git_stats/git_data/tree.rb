# -*- encoding : utf-8 -*-
# require 'git_stats/hash_initializable'

module GitStats
  module GitData
    class Tree
      include HashInitializable
      attr_reader :repo, :sha, :filename
      def initialize(params)
        super(params)
      end

      def to_s
        "#{self.class} #@sha #@filename"
      end

    end
  end
end
