# Home73k

Personal website with blog.

## Blog posts

Posts are markdown files stored under `priv/content` and parsed by [Earmark](https://hexdocs.pm/earmark/Earmark.html). This can be configured in `config.exs` under `config :home73k, :app_global_vars, blog_content: "path/to/content"`

### Syntax highlighting

For the challenge of it, and to keep user's browsers from having to run javascript just to highlight some code, I chose to do server-side syntax highlighting.

Due to the lexer limitations of elixir-native solutions, the highlighter uses [Pygments](https://pygments.org/) by calling [pygmentize](https://pygments.org/docs/cmdline/) via [System.cmd](https://hexdocs.pm/elixir/System.html#cmd/3)

However, this requires installing python3 & Pygments. Best way to do this is with a venv (virtual python environment), so you'll also want `python3-venv` installed on a debian system, for example.

By default, Home73k is configured to look for pygmentize in a venv at `priv/pygments/bin/pygmentize` -- here's a quick howto for how to set that up:

```shell
cd priv
python3 -m venv pygments
source pygments/bin/activate
pip3 install Pygments
```

The location of bin/pygmentize can be configured in `config.exs` under `config :home73k, :app_global_vars, pygmentize_bin: "path/to/bin/pygmentize"` 
