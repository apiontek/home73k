defmodule Home73kWeb.DateHelpers do
  @moduledoc """
  Formatters for dates
  """

  def format_date(date) do
    Calendar.strftime(date, "%B %-d, %Y")
  end
end
