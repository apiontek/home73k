defmodule Home73kWeb.FeedView do
  use Home73kWeb, :view

  import Home73k, only: [app_time_zone: 0]

  def to_rfc822(naive_dt) do
    naive_dt
    |> DateTime.from_naive!(app_time_zone())
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S %Z")
  end
end
