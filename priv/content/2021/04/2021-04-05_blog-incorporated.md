---
%{
  title: "Blog, Incorporated",
  id: "blog-incorporated-2021",
  date: ~N[2021-04-05 23:49:00],
  author: "Adam Piontek",
  tags: ["blog", "tech", "coding", "web", "fun", "markdown", "elixir"]
}
---

After a few months working with [Writefreely, (kept separate from a static webpack-generated front page)](/blog/new-front-page-internet-home), I just really didn't like the feel of keeping a blog in separate software with a database, when the content itself was just markdown. Probably the thing to do would be to hop on the static site bandwagon, but I've been spending so much time learning elixir & phoenix for other projects, I didn't relish spending time learning a whole new toolchain.

Luckily, there are [good](http://www.sebastianseilund.com/static-markdown-blog-posts-with-elixir-phoenix) [resources](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) on basing a blog off markdown files in Elixir Phoenix, in a manner basically as speedy as a static site. So...

<!--more-->

I set to incorporating my blog posts and previous static webpack-based design into a Phoenix site. Had to do a few additions and customizations to get things working just right.

For one, as much as I love Elxiir, the only server-side syntax-highlighting package out there doesn't support enough languages for my needs. I didn't like the idea of using client-side javascript, so I decided to leverage [Chroma's cli](https://github.com/alecthomas/chroma#command-line-interface). Hooking elixir's System.cmd/3 in with a trimmed & modified version of [the ExDoc syntax highlighter code](https://github.com/elixir-lang/ex_doc/blob/d5cde30f55c7e0cde486ec3878067aee82ccc924/lib/ex_doc/highlighter.ex), after parsing the markdown to html, I'm able to isolate all fenced code in a post, write each code fragment to a temp file, apply highlight classes via chroma, and replace the code in the post.

*(As an aside, I at first tried using [Pygments' `pygmentize` cli](https://pygments.org/docs/cmdline/), which worked fine, but I realized it didn't seem to support vue templates, and I do some work with vue. At some point it might be fun to try to figure out how to implement the lexers I need in the elixir native project [makeup](https://github.com/elixir-makeup/makeup) but that's a big task to tackle some other day!)*

I also found code hot-reloading wasn't working great if I added or removed a file, even if I canceled all elixir processes and started it up again. I had to get this fixed because the plan was to deploy new content and other changes via git repository post-receive hook, and while I can script the recompilation, and probably add in a `--force` flag or something, I wanted it cleaner. Plus I just wanted the convenience of writing posts in dev mode with a preview.

The Dashbit posts referenced above on basing an elixir site off markdown files both cover basic live reloading, but I found I needed to add the following to my Blog module to ensure it was recompiled:

```elixir
post_paths_hash = :erlang.md5(post_paths)

def __mix_recompile__?() do
  Path.wildcard("content/**/*.md")
  |> :erlang.md5() != unquote(post_paths_hash)
end
```

Following that change, new markdown files are recognized and included as expected.

And, FWIW, here's the meat of my modified highlighter using chroma (NOTE: the CSS styles can be exported separately (like so: `~/go/bin/chroma -s base16-snazzy --html-styles > _chroma.css`), or you can use styles from Pygments, including custom styles like [nord_pygments](https://github.com/sbrisard/nord_pygments)). Once included in your app.scss, if you use purgecss like me, you'll need to add the chroma class (or whatever class you're using) to the safelist for the webpack plugin: `safelist: {greedy: [/phx/, /topbar/, /inline/, /chroma/]}` .)

```elixir
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
  # The '@chroma_bin' module attribute retrieves the configured
  # location of the chroma cli binary from the application config.
  {highlighted, _} = System.cmd(@chroma_bin, bin_args)

  # return properly wrapped highlighted code
  ~s(<pre class="chroma"><code class="language-#{lang}">#{highlighted}</code></pre>)
end
```