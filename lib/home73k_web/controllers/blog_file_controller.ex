defmodule Home73kWeb.BlogFileController do
  use Home73kWeb, :controller

  @moduledoc """
  This controller handles path requests that didn't match an existing route,
  including the main Plug.Static for the / root path.

  To handle this situation, we'll check if the requested resource exists as
  a file under the blog content repo folder, by querying the Blog genserve.

  If it exists, we'll redirect to the blog content static path under /_
  Otherwise, we'll return 404 not found.
  """

  alias Home73k.Repo
  alias Home73k.Blog

  def index(conn, _params) do
    # What would be the content path of this requested resource?
    content_path = Repo.content_path() |> Path.join(conn.request_path)

    # Check if it exists in the Blog's known files
    Blog.get_files()
    |> Enum.member?(content_path)
    |> case do
      true -> redirect(conn, to: "/_#{conn.request_path}")
      false -> send_resp(conn, 404, "not found")
    end
  end
end
