defmodule Home73k.Blog.Post do
  @enforce_keys [:title, :slug, :date, :author, :tags, :lede, :body, :corpus]
  defstruct [:title, :slug, :date, :author, :tags, :lede, :body, :corpus]

  @strip_words ~w(the and are for not but had has was all any too one you his her can that with have this will your from they want been much some very them into which then now get its youll youre)

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
    |> parse_body()
    |> build_corpus()
    |> build_post()
  end

  # """ split_raw_file_data/1
  # If we receive {:ok, file_data}, we split frontmatter from markdown
  # content and return [raw_frontmatter, markdown]. Otherwise return nil.
  # """
  defp split_raw_file_data({:ok, file_data}) do
    file_data |> String.split("---", parts: 2, trim: true)
  end

  defp split_raw_file_data(_), do: nil

  # """ parse_frontmatter/1
  # If we receive [raw_frontmatter, markdown], we parse the frontmatter.
  # Otherwise, return nil.
  # """
  defp parse_frontmatter([fm, md]) do
    case parse_frontmatter_string(fm) do
      {%{} = parsed_fm, _} -> {set_post_slug(parsed_fm), String.trim(md)}
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

  # """ parse_body/1
  # Convert body markdown to html
  # TODO: handle syntax highlighting
  defp parse_body({fm, md}) do
    Map.put(fm, :body, Earmark.as_html!(md))
  end

  defp parse_body(_), do: nil

  # """ build_corpus/1
  # Create a searchable word list for the post, for live searching
  defp build_corpus(%{title: title, lede: lede, body: body, tags: tags} = post_data) do
    # initialize corpus string from: title, lede, body, tags
    corpus = (tags ++ [title, (lede && lede) || " ", body]) |> Enum.join(" ") |> String.downcase()

    # scrub out (but replace with spaces):
    # code blocks, html tags, html entities, newlines, forward and back slashes
    html_scrub_regex = ~r/(<pre><code(.|\n)*?<\/code><\/pre>)|(<(.|\n)+?>)|(&#(.)+?;)|(&(.)+?;)|\n|\/|\\/
    corpus = Regex.replace(html_scrub_regex, corpus, " ")

    # restrict corpus to letters & numbers,
    # then split to words (space delim), trimming as we go
    # then reject short & common words
    # reduce to unique words and join back to space-delim string
    corpus =
      Regex.replace(~r/[^a-z0-9 ]/, corpus, "")
      |> String.split(" ", trim: true)
      |> Stream.reject(&reject_word?/1)
      |> Stream.uniq()
      |> Enum.join(" ")

    # Finally, return post_data with corpus
    Map.put(post_data, :corpus, corpus)
  end

  defp build_corpus(_), do: nil

  # """ build_post/1
  # Create post struct from post data map
  defp build_post(%{} = post_data) do
    struct!(__MODULE__, post_data)
  end

  defp build_post(_), do: nil

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
  defp extract_lede([lede, body]),
    do: {String.trim_trailing(lede) |> Earmark.as_html!(), String.trim_leading(body)}

  defp extract_lede([body]), do: {nil, body}

  # """ set_frontmatter_slug
  # If no slug in frontmatter, convert title to slug and add to map
  # """
  defp set_post_slug(%{slug: _} = fm), do: fm

  defp set_post_slug(%{title: title} = fm) do
    Map.put(fm, :slug, parse_title_to_slug(title))
  end

  # """ parse_title_to_slug
  # Takes a post title and returns a slug cleansed for URI request path
  # """
  defp parse_title_to_slug(title) do
    title = String.downcase(title)

    Regex.replace(~r/[^a-z0-9 ]/, title, "")
    |> String.split(" ", trim: true)
    |> Stream.reject(&reject_word?/1)
    |> Enum.join("-")
  end

  # """ reject_word?
  # Returns true to reject short or common words
  # Used by parse_title_to_slug and build_corpus
  # """
  defp reject_word?(word), do: String.length(word) < 3 || word in @strip_words
end