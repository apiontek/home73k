defmodule Home73kWeb.FeedController do
  use Home73kWeb, :controller

  alias Home73k.Blog

  def rss(conn, _params) do
    posts = Blog.list_posts()
    last_build_date = posts |> List.first() |> Map.get(:date)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> put_layout(:false)
    |> render("rss.xml", posts: posts, last_build_date: last_build_date)
  end
end
