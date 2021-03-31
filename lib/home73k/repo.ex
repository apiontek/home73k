defmodule Home73k.Repo do
  @repo_url Application.compile_env(:home73k, [:content_repo, :url], nil)
  @content_path Application.compile_env(:home73k, [:content_repo, :path], "./priv/content")
                |> Path.expand()

  ######################################################################
  # REPO SETUP
  ######################################################################
  def get do
    @content_path |> File.exists?() |> init_repo()
  end

  def content_path, do: @content_path

  # If content path is absent, clone repo if url is present
  defp init_repo(false) do
    if @repo_url do
      {:ok, repo} = Git.clone([@repo_url, @content_path])
      repo
    else
      nil
    end
  end

  # If content path exists, check for .git child and pull or return nil
  defp init_repo(true) do
    if git_data_dir_ok?() do
      Git.new(@content_path)
    else
      nil
    end
  end

  defp git_data_dir_ok? do
    git_data_dir = Path.join(@content_path, ".git")
    File.exists?(git_data_dir) && File.dir?(git_data_dir)
  end

  ######################################################################
  # REPO OPERATIONS
  ######################################################################
  def update(repo), do: Git.pull(repo)
end
