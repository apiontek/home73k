defmodule Home73kWeb.PageLive do
  use Home73kWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, query: "", results: %{}, page_title: "~")
     |> put_flash(:success, "Log in was a success. Good for you.")
     |> put_flash(:error, "Lorem ipsum dolor sit amet consectetur adipisicing elit.")
     |> put_flash(
       :info,
       "Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatibus dolore sunt quia aperiam sint id reprehenderit? Dolore incidunt alias inventore accusantium nulla optio, ducimus eius aliquam hic, pariatur voluptate distinctio."
     )
     |> put_flash(:warning, "Oh no, there's nothing to worry about!")
     |> put_flash(:primary, "Something in the brand color.")}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not Home73kWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
