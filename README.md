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

## Deploying

### New versions

When improvements are made, we can update the deployed version like so:

```shell
cd /opt/home73k
git pull
mix deps.get --only prod
MIX_ENV=prod mix compile
# update chroma in priv gopath
GOPATH=$(pwd)/priv/go go get -u github.com/alecthomas/chroma/cmd/chroma
# rebuild static assets:
rm -rf priv/static/*
npm run deploy --prefix ./assets
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix release --overwrite
# test starting it:
MIX_ENV=prod _build/prod/rel/home73k/bin/home73k start
```

### systemd unit:

```ini
[Unit]
Description=Home73k service
After=local-fs.target network.target

[Service]
Type=simple
User=runuser
Group=runuser
WorkingDirectory=/opt/home73k/_build/prod/rel/home73k
ExecStart=/opt/home73k/_build/prod/rel/home73k/bin/home73k start
ExecStop=/opt/home73k/_build/prod/rel/home73k/bin/home73k stop
#EnvironmentFile=/etc/default/myApp.env
Environment=LANG=en_US.utf8
Environment=MIX_ENV=prod
#Environment=PORT=4000
LimitNOFILE=65535
UMask=0027
SyslogIdentifier=home73k
Restart=always

[Install]
WantedBy=multi-user.target
```

### nginx config:

```conf
    upstream phoenixhome {
      server 127.0.0.1:4721 max_fails=5 fail_timeout=60s;
    }
    server {
      location / {
        allow all;
        # Proxy Headers
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Cluster-Client-Ip $remote_addr;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_redirect off;
        # WebSockets
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://phoenixhome;
      }
    }
```