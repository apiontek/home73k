defmodule Home73kWeb.PostLive do
  use Home73kWeb, :live_view

  alias Home73k.Blog

  @impl true
  def mount(%{"id" => id}, session, socket) do
    # IO.inspect(params, label: "postlive params")
    IO.inspect(session, label: "postlive session")

    post = Blog.get_post_by_id!(id)

    socket
    |> assign(:page_title, "Blog \\ #{post.title}")
    |> assign(:post, post)
    |> live_okreply()
  end

  # @impl true
  # def handle_params(params, _url, socket) do
  #   socket
  #   |> assign(:page_title, "Blog")
  #   |> assign(:posts, Blog.list_posts())
  #   |> live_noreply()
  # end

  # @impl true
  # def handle_event("suggest", %{"q" => query}, socket) do
  #   {:noreply, assign(socket, results: search(query), query: query)}
  # end

  # @impl true
  # def handle_event("search", %{"q" => query}, socket) do
  #   case search(query) do
  #     %{^query => vsn} ->
  #       {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

  #     _ ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:error, "No dependencies found matching \"#{query}\"")
  #        |> assign(results: %{}, query: query)}
  #   end
  # end

  # defp search(query) do
  #   if not Home73kWeb.Endpoint.config(:code_reloader) do
  #     raise "action disabled when not in development"
  #   end

  #   for {app, desc, vsn} <- Application.started_applications(),
  #       app = to_string(app),
  #       String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
  #       into: %{},
  #       do: {app, vsn}
  # end

end
