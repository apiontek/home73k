defmodule Home73k.Highlighter do
  @moduledoc """
  Performs code highlighting.
  """

  alias Home73k.Temp

  @chroma_bin Home73k.app_chroma_bin() |> Path.expand()

  @doc """
  Highlights all code block in an already generated HTML document.
  """
  def highlight_code_blocks(html) do
    ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/
    |> Regex.replace(html, &highlight_code_block(&1, &2, &3))
  end

  defp highlight_code_block(_full_block, lang, code) do
    # unescape the code
    unescaped_code = unescape_html(code) |> IO.iodata_to_binary()

    # write code to temp file
    tmp_file = Temp.file()
    File.write!(tmp_file, unescaped_code)

    # use chroma to highlight the code via temp file
    bin_args = ["-l", lang, "-f", "html", "--html-only", "--html-prevent-surrounding-pre", tmp_file]
    {highlighted, _} = System.cmd(@chroma_bin, bin_args)

    # return properly wrapped highlighted code
    ~s(<pre class="chroma"><code class="language-#{lang}">#{highlighted}</code></pre>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest) do
      [unquote(decoded) | unescape_html(rest)]
    end
  end

  defp unescape_html(<<c, rest::binary>>) do
    [c | unescape_html(rest)]
  end

  defp unescape_html(<<>>) do
    []
  end
end
