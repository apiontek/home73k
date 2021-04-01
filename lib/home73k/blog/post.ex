defmodule Home73k.Blog.Post do
  @enforce_keys [:title, :slug, :date, :author, :tags, :summary, :body]
  defstruct [:title, :slug, :date, :author, :tags, :summary, :body]

  @title_slug_regex ~r/[^a-zA-Z0-9 ]/

  def parse!(post_path) do
    post_path
    |> File.read()
    |> parse_raw_file_data()
  end

  defp parse_raw_file_data({:ok, post_data}) do
    post_data
    |> String.split("---", parts: 3)
    |> parse_split_file_data()
  end

  defp parse_raw_file_data(_), do: nil

  defp parse_split_file_data(["", fm, md]) do
    Code.eval_string(fm)
    |> parse_summary(md)
  end

  defp parse_split_file_data(_), do: nil

  defp parse_summary({%{summary: summ} = fm, _}, md) do
    Earmark.as_html(md)
    |> parse_post(Earmark.as_html(summ), fm)
  end

  defp parse_summary({%{} = fm, _}, md) do
    String.split(md, "<!--more-->", parts: 2)
    |> parse_summary(fm)
  end

  defp parse_summary([summ, _] = parts, fm) do
    parts
    |> Enum.join(" ")
    |> Earmark.as_html()
    |> parse_post(Earmark.as_html(summ), fm)
  end

  defp parse_summary(md, fm) do
    Earmark.as_html(md)
    |> parse_post({:ok, nil, []}, fm)
  end

  defp parse_title_to_slug(title) do
    Regex.replace(@title_slug_regex, title, "")
    |> String.replace(" ", "-")
    |> String.downcase()
  end

  defp build_post(main_html, summ_html, fm) do
    fm
    |> Map.put_new(:slug, parse_title_to_slug(fm.title))
    |> Map.put_new(:author, "Author Name")
    |> Map.put_new(:tags, [])
    |> Map.put(:summary, summ_html)
    |> Map.put(:body, main_html)
  end

  defp parse_post({:ok, main_html, _}, {:ok, summ_html, _}, fm) do
    post = build_post(main_html, summ_html, fm)
    struct!(__MODULE__, post)
  end

  defp parse_post(_, _, _), do: nil
end
