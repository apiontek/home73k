defmodule Home73k.Blog do
  alias Home73k.Blog.Post

  Application.ensure_all_started(:earmark)

  @content_path Application.compile_env(:home73k, [:content_repo, :path], "./priv/content")
                |> Path.expand()

  posts_paths =
    @content_path
    |> Path.join("**/*.md")
    |> Path.wildcard()

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  # @posts posts
  @posts Enum.sort_by(posts, & &1.date, {:desc, NaiveDateTime})

  @tags posts |> Stream.flat_map(& &1.tags) |> Stream.uniq() |> Enum.sort()

  def list_posts, do: @posts
  def list_tags, do: @tags

  # defmodule NotFoundError do
  #   defexception [:message, plug_status: 404]
  # end

  # def get_posts_by_tag!(tag) do
  #   case Enum.filter(list_posts(), &(tag in &1.tags)) do
  #     [] -> raise NotFoundError, "posts with tag=#{tag} not found"
  #     posts -> posts
  #   end
  # end
end
