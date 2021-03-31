defmodule Home73k.Blog do
  use GenServer

  #
  # Setup
  #
  Application.ensure_all_started(:earmark)

  @repo Home73k.Repo.get()

  #
  # Client
  #

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{posts: [], tags: [], files: []}, name: __MODULE__)
  end

  def get_posts() do
    GenServer.call(__MODULE__, :get_posts)
  end

  def get_files() do
    GenServer.call(__MODULE__, :get_files)
  end

  # def push(pid, element) do
  #   GenServer.cast(pid, {:push, element})
  # end

  # def pop(pid) do
  #   GenServer.call(pid, :pop)
  # end

  # def put(server, key, value) do
  #   GenServer.cast(server, {:put, key, value})
  # end

  # def get(server, key) do
  #   GenServer.call(server, {:get, key})
  # end

  #
  # Server
  #

  @impl true
  def init(state) do
    repo_all_paths = @repo.path |> Path.join("**/*.*") |> Path.wildcard()
    repo_post_paths = repo_all_paths |> Enum.filter(fn f -> String.ends_with?(f, ".md") end)
    repo_file_paths = repo_all_paths |> Enum.filter(fn f -> !String.ends_with?(f, ".md") end)
    {:ok, %{state | posts: repo_post_paths, files: repo_file_paths}}
  end

  @impl true
  def handle_call(:get_posts, _from, %{posts: posts} = state) do
    {:reply, posts, state}
  end

  @impl true
  def handle_call(:get_files, _from, %{files: files} = state) do
    {:reply, files, state}
  end

  # @impl true
  # def handle_call(:pop, _from, [head | tail]) do
  #   {:reply, head, tail}
  # end

  # @impl true
  # def handle_cast({:push, element}, state) do
  #   {:noreply, [element | state]}
  # end

  # def handle_cast({:put, key, value}, state) do
  #   {:noreply, Map.put(state, key, value)}
  # end

  # def handle_call({:get, key}, _from, state) do
  #   {:reply, Map.fetch!(state, key), state}
  # end

  # alias Home73k.Blog.Post

  # @posts_dir Application.compile_env(:home73k, :blog_posts_dir, "posts")

  # posts_paths =
  #   @posts_dir
  #   |> Path.join("**/*.md")
  #   |> Path.wildcard()
  #   |> Enum.sort()

  # posts =
  #   for post_path <- posts_paths do
  #     @external_resource Path.relative_to_cwd(post_path)
  #     Post.parse!(post_path)
  #   end

  # @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  # @tags posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # def list_posts, do: @posts
  # def list_tags, do: @tags

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
