defmodule Home73k.Highlighter do
  @moduledoc """
  Performs code highlighting.
  """

  import Home73k, only: [app_chroma_bin: 0]
  alias Home73k.Temp

  @chroma_bin app_chroma_bin() |> Path.expand()

  @doc """
  Highlights all code in HTML (fenced code blocks and inlined code)
  """
  def highlight_all(html) do
    highlight_code_blocks(html) |> highlight_code_inlined()
  end

  @doc """
  Highlights fenced code blocks in HTML document
  """
  def highlight_code_blocks(html) do
    ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/
    |> Regex.replace(html, &highlight_code_block(&1, &2, &3))
  end

  defp highlight_code_block(_full_block, lang, code) do
    # perform the code highlighting
    highlighted = highlight_code(lang, code)
    # return properly wrapped highlighted code
    ~s(<pre class="chroma"><code class="language-#{lang}">#{highlighted}</code></pre>)
  end

  @doc """
  Highlights inlined code in HTML document
  """
  def highlight_code_inlined(html) do
    ~r/<code(?:\s+class="inline lang-(\w*)")?>([^<]*)<\/code>/
    |> Regex.replace(html, &highlight_code_inline(&1, &2, &3))
  end

  defp highlight_code_inline(_full_block, lang, code) do
    # perform the code highlighting
    highlighted = highlight_code(lang, code)
    # return properly wrapped highlighted code
    ~s(<code class="inline chroma language-#{lang}">#{highlighted}</code>)
  end

  # """
  # Performs code highlighting using chroma
  # """
  defp highlight_code(lang, code) do
    # unescape the code
    unescaped_code = unescape_html(code) |> IO.iodata_to_binary()

    # write code to temp file
    tmp_file = Temp.file()
    File.write!(tmp_file, unescaped_code)

    # use chroma to highlight the code via temp file
    bin_args = ["-l", lang, "-f", "html", "--html-only", "--html-prevent-surrounding-pre", tmp_file]
    System.cmd(@chroma_bin, bin_args) |> elem(0)
  end

  # """
  # Code below for unescaping html, since it's escaped by Earmark markdown parsing
  # """
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
