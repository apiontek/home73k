defmodule Home73kWeb.BlogLive do
  use Home73kWeb, :live_view

  alias Home73k.Blog

  @page_size 7

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket.assigns.live_action
    |> init_per_live_action(socket, params)
    |> live_noreply()
  end

  defp page_param_as_int(page) do
    try do
      String.to_integer(page)
    rescue
      _ -> nil
    end
  end

  defp raise_not_found(msg), do: raise Home73k.Blog.NotFoundError, msg

  defp init_per_live_action(:index, socket, _params) do
    socket
    |> assign(:page_title, "Blog")
    |> assign(:posts, get_posts_for_page!(1))
    |> assign(:page_count, get_page_count())
    |> assign_prev_next(1)
  end

  defp init_per_live_action(:page, socket, %{"page" => page}) do
    page_int = page_param_as_int(page)
    page_count = get_page_count()

    cond do
      is_nil(page_int) || page_int <= 1 ->
        push_patch(socket, to: Routes.blog_path(socket, :index))

      page_int > page_count ->
        raise_not_found("there are only #{page_count} pages of posts")

      true ->
        posts = get_posts_for_page!(page_int)

        socket
        |> assign(:page_title, "Blog \\ Page #{page}")
        |> assign(:posts, posts)
        |> assign(:page_count, page_count)
        |> assign_prev_next(page_int)
    end
  end

  defp init_per_live_action(:show, socket, %{"id" => id}) do
    post = Blog.get_post_by_id!(id)
    socket
    |> assign(:page_title, "Blog \\ post.title")
    |> assign(:posts, [post])
    |> assign(:page_count, nil)
    |> assign_prev_next(0)
  end

  defp init_per_live_action(:tag, socket, %{"tag" => tag}) do
    socket
    |> assign(:page_title, "Blog \\ ##{tag}")
    |> assign(:posts, Blog.get_posts_by_tag!(tag))
    |> assign(:page_count, get_page_count())
    |> assign_prev_next(1)
  end


  defp get_posts_for_page!(1), do: Blog.list_posts() |> Enum.take(@page_size)

  defp get_posts_for_page!(page_int) do
    Blog.list_posts()
    |> Stream.chunk_every(@page_size)
    |> Enum.at(page_int - 1)
  end

  defp get_page_count, do: Integer.floor_div(Blog.post_count(), @page_size) + rem(Blog.post_count(), @page_size)

  defp assign_prev_next(socket, page_int) do
    socket
    |> assign(:page_prev, page_int < socket.assigns.page_count && page_int + 1 || nil)
    |> assign(:page_next, page_int > 1 && page_int - 1 || nil)
  end


  def format_date(date) do
    Calendar.strftime(date, "%B %-d, %Y")
  end
end
