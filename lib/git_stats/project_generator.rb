# -*- encoding : utf-8 -*-
module GitStats
  class ProjectGenerator
    delegate :add_command_observer, to: :@repo

    def initialize(repo_path, out_path, first_commit_sha = nil, last_commit_sha = "HEAD", tree_path = ".", level = 1)
      validate_repo_path(repo_path)

      @repo = GitData::Repo.new(path: repo_path,
                                first_commit_sha: first_commit_sha,
                                last_commit_sha: last_commit_sha,
                                tree_path: tree_path)

      @view = []
      view_data = StatsView::ViewData.new(@repo)
      @view << StatsView::View.new(view_data, out_path)
      @repo.trees.each do |tree|
        if (tree.filename.count("/") + 1 ) <= level
          puts "Generating #{tree.filename} in #{File.join(out_path, tree.filename)}"
          view_data = StatsView::ViewData.new(@repo.tree(tree.filename))
          @view << StatsView::View.new(view_data, File.join(out_path, tree.filename) , out_path) # TODO Comment out the last part to have assets in each subdir
        end
      end

      yield self if block_given?
    end

    def render_all
      @view.each do |view|
        puts "Rendering #{view.view_data.repo}"
        view.render_all
      end
    end


    private

    def validate_repo_path(repo_path)
      raise ArgumentError, "#{repo_path} is not a git repository" unless Validator.new.valid_repo_path?(repo_path)
    end

  end

end
