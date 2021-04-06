defmodule Home73kWeb.LayoutView do
  use Home73kWeb, :view

  def navbar_fixed?(conn) do
    [:index, :folio]
    |> Enum.map(&Routes.home_path(conn, &1))
    |> Enum.member?(Phoenix.Controller.current_path(conn))
  end

  def footer_absolute?(conn) do
    [:index, :folio, :resume]
    |> Enum.map(&Routes.home_path(conn, &1))
    |> Enum.member?(Phoenix.Controller.current_path(conn))
  end

  def nav_link_opts(conn, opts) do
    case Keyword.get(opts, :to) == Phoenix.Controller.current_path(conn) do
      false -> opts
      true -> Keyword.update(opts, :class, "active", fn c -> "#{c} active" end)
    end
  end
end
