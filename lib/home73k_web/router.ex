defmodule Home73kWeb.Router do
  use Home73kWeb, :router
  alias Home73kWeb.CSPHeader

  pipeline :browser do
    plug :accepts, ~w(html xml)
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Home73kWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CSPHeader
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Home73kWeb do
    pipe_through :browser

    # Pages
    get "/", HomeController, :index
    get "/about", HomeController, :about
    get "/resume", HomeController, :resume
    get "/folio", HomeController, :folio
    get "/err", HomeController, :err
    get "/err/:code", HomeController, :err

    # Blog
    live "/blog", BlogLive, :index
    live "/blog/page/:page", BlogLive, :page
    live "/blog/tag/:tag", BlogLive, :tag
    live "/blog/:id", BlogLive, :show

    # Feeds
    get "/feed", FeedController, :rss
  end

  # Other scopes may use custom stacks.
  # scope "/api", Home73kWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: Home73kWeb.Telemetry
    end
  end
end
