defmodule Home73k.Blog do
  @moduledoc """
  Blog content loading & data access functions.
  """
  import Home73k, only: [app_blog_content: 0]
  alias Home73k.Blog.Post

  Application.ensure_all_started(:earmark)

  post_paths = "#{app_blog_content()}/**/*.md" |> Path.wildcard()
  post_paths_hash = :erlang.md5(post_paths)

  posts =
    for post_path <- post_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  def __mix_recompile__?() do
    Path.wildcard("#{app_blog_content()}/**/*.md")
    |> :erlang.md5() != unquote(post_paths_hash)
  end

  @posts Enum.sort_by(posts, & &1.date, {:desc, NaiveDateTime})
  @post_count length(@posts)



  defp list_all_posts, do: @posts
  defp list_posts_reject_future, do: list_all_posts() |> Enum.reject(&(&1.date <= NaiveDateTime.utc_now()))

  # Enum reject posts with future date, allowing scheduled posts
  def list_posts, do: list_posts_reject_future()

  # List tags, but not for future p
  def list_tags do
    list_all_posts()
    |> Stream.reject(&(&1.date <= NaiveDateTime.utc_now()))
    |> Stream.flat_map(& &1.tags)
    |> Stream.uniq()
    |> Enum.sort()
  end

  def post_count, do: @post_count

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def get_post_by_id!(id) do
    case Enum.find(list_posts(), nil, &(&1.id == id)) do
      %Post{} = post -> post
      nil -> raise NotFoundError, "post with id=#{id} not found"
    end
  end

  def get_posts_by_tag!(tag) do
    case Enum.filter(list_posts(), &(tag in &1.tags)) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end
end
