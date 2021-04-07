defmodule Home73kWeb.ErrController do
  use Home73kWeb, :controller
  plug :put_layout, false
  plug :put_root_layout, false

  @valid_codes [
    400,
    401,
    402,
    403,
    404,
    405,
    406,
    407,
    408,
    409,
    410,
    411,
    412,
    413,
    414,
    415,
    416,
    417,
    418,
    421,
    422,
    423,
    424,
    425,
    426,
    428,
    429,
    431,
    451,
    500,
    501,
    502,
    503,
    504,
    505,
    506,
    507,
    508,
    510,
    511
  ]

  def err(conn, params) do
    code = Map.get(params, "code", "404") |> err_code_as_int()
    code = (code in @valid_codes && code) || 404

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
