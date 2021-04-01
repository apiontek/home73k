defmodule Home73k.Blog.Post do
  @enforce_keys [:title, :slug, :date, :author, :tags, :lede, :body]
  defstruct [:title, :slug, :date, :author, :tags, :lede, :body]

  @title_slug_regex ~r/[^a-zA-Z0-9 ]/

  @doc """
  The public parse!/1 function begins the post parse process by reading
  the file. By passing through a series of other functions, it ultimately
  returns either a %Post{} or nil.
  """
  def parse!(post_path) do
    post_path
    |> File.read()
    |> split_raw_file_data()
    |> parse_frontmatter()
    |> parse_lede()
  end

  # """ split_raw_file_data/1
  # If we receive {:ok, file_data}, we split frontmatter from markdown
  # content and return [raw_frontmatter, markdown]. Otherwise return nil.
  # """
  defp split_raw_file_data({:ok, file_data}), do: String.split(file_data, ~r/\n-{3,}\n/, parts: 2)
  defp split_raw_file_data(_), do: nil

  # """ parse_frontmatter/1
  # If we receive [raw_frontmatter, markdown], we parse the frontmatter.
  # Otherwise, return nil.
  # """
  defp parse_frontmatter([fm, md]) do
    case parse_frontmatter_string(fm) do
      {%{} = parsed_fm, _} -> {parsed_fm, md}
      {:error, _} -> nil
    end
  end

  defp parse_frontmatter(nil), do: nil

  # """ parse_lede/1
  # Look for lede/excerpt/summary in content and extract it if present.
  # We return updated frontmatter, and content with <!--more--> stripped.
  defp parse_lede({fm, md}) do
    {lede, body_md} = String.split(md, "<!--more-->", parts: 2) |> extract_lede()
    {Map.put(fm, :lede, lede), String.replace(body_md, "<!--more-->", " ")}
  end

  defp parse_lede(_), do: nil

  # TODO:
  # |> parse_body()
  #     - convert to markdown
  #     - extract any code parts to mark with pygments?
  #     - figure that whole thing out

  ######################################################################
  # HELPERS
  ######################################################################

  # """ parse_frontmatter_string/1
  # We expect raw frontmatter as a string that evaluates to an elixir
  # map, so we try Code.eval_string/1 and rescue with nil if that raises
  # """
  defp parse_frontmatter_string(fm) do
    try do
      String.trim_leading(fm, "-")
      |> Code.eval_string()
    rescue
      _ -> {:error, nil}
    end
  end

  # """ extract_lede
  # Handle split of post body. If lede found, return as html with body.
  # Otherwise return nil with body.
  # """
  defp extract_lede([lede, body]), do: {Earmark.as_html!(lede), body}
  defp extract_lede([body]), do: {nil, body}

  # ##################################################
  # ##################################################
  # ##################################################
  # ##################################################
  # ##################################################
  # defp parse_split_file_data(["", fm, md]) do
  #   Code.eval_string(fm)
  #   |> parse_lede(md)
  # end

  # defp parse_split_file_data(_), do: nil

  # defp parse_lede({%{summary: summ} = fm, _}, md) do
  #   Earmark.as_html(md)
  #   |> parse_post(Earmark.as_html(summ), fm)
  # end

  # defp parse_lede({%{} = fm, _}, md) do
  #   String.split(md, "<!--more-->", parts: 2)
  #   |> parse_lede(fm)
  # end

  # defp parse_lede([summ, _] = parts, fm) do
  #   parts
  #   |> Enum.join(" ")
  #   |> Earmark.as_html()
  #   |> parse_post(Earmark.as_html(summ), fm)
  # end

  # defp parse_lede(md, fm) do
  #   Earmark.as_html(md)
  #   |> parse_post({:ok, nil, []}, fm)
  # end

  # defp parse_title_to_slug(title) do
  #   Regex.replace(@title_slug_regex, title, "")
  #   |> String.replace(" ", "-")
  #   |> String.downcase()
  # end

  # defp build_post(main_html, summ_html, fm) do
  #   fm
  #   |> Map.put_new(:slug, parse_title_to_slug(fm.title))
  #   |> Map.put_new(:author, "Author Name")
  #   |> Map.put_new(:tags, [])
  #   |> Map.put(:summary, summ_html)
  #   |> Map.put(:body, main_html)
  # end

  # defp parse_post({:ok, main_html, _}, {:ok, summ_html, _}, fm) do
  #   post = build_post(main_html, summ_html, fm)
  #   struct!(__MODULE__, post)
  # end

  # defp parse_post(_, _, _), do: nil
end
