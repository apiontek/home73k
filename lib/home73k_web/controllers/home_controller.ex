defmodule Home73kWeb.HomeController do
  use Home73kWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def about(conn, _params) do
    render(conn, "about.html", page_title: "About")
  end

  def resume(conn, _params) do
    render(conn, "resume.html", page_title: "Résumé")
  end

  def folio(conn, _params) do
    render(conn, "folio.html", page_title: "Folio")
  end
end
