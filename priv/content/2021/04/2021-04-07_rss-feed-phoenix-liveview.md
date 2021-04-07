---
%{
  title: "RSS Feed When Using Elixir Phoenix LiveView",
  id: "rss-feed-elixir-phoenix-liveview",
  date: ~N[2021-04-07 12:31:00],
  author: "Adam Piontek",
  tags: ~w(tech elixir phoenix liveview coding routing rss feed development)
}
---

While [re-implementing my website in elixir/phoenix](/blog/blog-incorporated-2021), I wanted to include an RSS feed for the blog posts. Luckily I found pretty much everything I needed in Daniel Wachtel's [Building an RSS Feed with Phoenix](https://danielwachtel.com/phoenix/building-rss-feed-phoenix) post, but since I'm making use of LiveView, I ran into one hiccup --- errors about a missing `root.xml` layout!

<!--more-->

LiveView changes how Phoenix handles layouts --- there's a `root.html.leex` layout, and then for live views, a `live.html.leex` sub-layout, and for regular controller views, an `app.html.eex` sub-layout.

Without LiveView, Daniel's controller directive `plug :put_layout, false`{:.lang-elixir} would be enough, but with LiveView, Phoenix is still looking for the *root* layout template, which for my `index.html` would be `root.xml` ... what to do?

One option would be to create a whole separate router pipeline to skip the `plug :put_root_layout, {Home73kWeb.LayoutView, :root}`{:.lang-elixir} directive. It would work, but is a heavier approach.

But luckily, there's a new [put_root_layout/2](https://hexdocs.pm/phoenix/Phoenix.Controller.html#put_root_layout/2) that we can leverage like so:

```elixir
defmodule YourAppWeb.RSSController do
  use YourAppWeb, :controller
  plug :put_layout, false
  plug :put_root_layout, false

  ...
end
```

With this in place, the rss xml is served plain, just like we want.
