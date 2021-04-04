defmodule Home73k.Blog do
  alias Home73k.Blog.Post

  Application.ensure_all_started(:earmark)

  posts_paths = "priv/content/**/*.md" |> Path.wildcard()

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, NaiveDateTime})

  @tags posts |> Stream.flat_map(& &1.tags) |> Stream.uniq() |> Enum.sort()

  def list_posts, do: @posts
  def list_tags, do: @tags

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def get_post_by_id!(id) do
    case Enum.find(list_posts(), nil, &(&1.id == id)) do
      %Post{} = post -> post
      nil -> raise NotFoundError, "post with id=#{id} not found"
    end
  end

  # def get_posts_by_tag!(tag) do
  #   case Enum.filter(list_posts(), &(tag in &1.tags)) do
  #     [] -> raise NotFoundError, "posts with tag=#{tag} not found"
  #     posts -> posts
  #   end
  # end
end
