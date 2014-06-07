# -*- encoding : utf-8 -*-
module GitStats
  module StatsView
    class ViewData
      include ActionView::Helpers::TagHelper
      include LazyHighCharts::LayoutHelper
      attr_reader :repo

      def initialize(repo)
        @repo = repo
      end

      def charts
        @charts ||= Charts::All.new(repo)
      end

      def render_partial(template_name, params = {})
        Template.new(template_name).render(self, params)
      end

      def asset_path(asset, active_page)
        Pathname.new("/assets/#{asset}").relative_path_from(Pathname.new("/#{@repo.tree_path}/#{active_page}").dirname)
      end

      def link_to(href, active_page)
        Pathname.new("/#{href}").relative_path_from(Pathname.new("/#{active_page}").dirname)
      end

      def tree_view_json(active_page)
        
        tree_view = (@repo.parent || @repo).trees.map{ |tree| tree.filename}
        require 'pathname'
        parent_relative_path = Pathname.new(".").relative_path_from(Pathname.new("#{@repo.tree_path}/#{Pathname.new(active_page).dirname}"))
        # puts "repo.tree_path: #{@repo.tree_path} parent_relative_path: #{parent_relative_path} active_page: #{active_page}"
        require 'json'
        json_tree = JSON.pretty_generate(generate_tree_view_hash(tree_view, parent_relative_path, (@repo.parent || @repo).project_name))
        json_tree
      end

      private

      def hash_to_tree_view_json(h, parent)
        output = []
        h.each do |k,v|
          output << {
            text: k,
            children: hash_to_tree_view_json(v, "#{parent}/#{k}"),
            a_attr: { href: "#{parent}/#{k}/index.html"} }
        end
        output
      end

      def generate_tree_view_hash(paths, parent_relative_path, parent_name = "/")
        auto_hash = Hash.new{ |h,k| h[k] = Hash.new &h.default_proc }

        paths.each{ |path|
          sub = auto_hash
          path.split( "/" ).each{ |dir| sub = sub[dir] }
        }
        result =  {text: parent_name, children: hash_to_tree_view_json(auto_hash, parent_relative_path),  a_attr: { href: "#{parent_relative_path}/index.html"}  }
        # state: {opened:true}, 
      end

    end
  end
end

