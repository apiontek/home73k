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

  @valid_codes [400..418, 421..426, 428..429, 500..508]
    |> Enum.map(&Enum.to_list/1)
    |> Enum.concat()
    |> Enum.concat([431, 451, 510, 511])

  def err(conn, params) do
    code = Map.get(params, "code", "404") |> err_code_as_int()
    code = code in @valid_codes && code || 404

    conn
    |> put_status(code)
    |> put_layout(false)
    |> put_root_layout(false)
    |> put_view(Home73kWeb.ErrorView)
    |> render("#{code}.html")
  end

  defp err_code_as_int(code) do
    try do
      String.to_integer(code)
    rescue
      _ -> 404
    end
  end
end
