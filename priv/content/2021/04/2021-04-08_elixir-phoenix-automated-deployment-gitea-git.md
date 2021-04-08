---
%{
  title: "Elixir Phoenix Automated Deployment with Gitea/systemd",
  id: "elixir-phoenix-automated-deployment-gitea-systemd-git",
  date: ~N[2021-04-08 17:49:00],
  author: "Adam Piontek",
  tags: ~w(tech elixir phoenix notes coding automated deployment gitea git systemd)
}
---

I don't know if this is the *"right"* way to do this, but it's working for me at the moment, and since it took a bit to figure out, I figured I'd write up my notes.

My needs are simple: when I'm happy with an update to my blog, or another elixir phoenix app I run, Shift73k (or more in the future), I'd like to be able to just commit to my repository, and then have those changes go live. At the moment I run both gitea and my other little apps on the same Linode, so I was able to set it up like this:

<!--more-->

### deployment script

First, the Phoenix deployment makes use of [Releases](https://hexdocs.pm/phoenix/releases.html), though I'm not doing anything fancy to track versions or anything like that.

This means the general upload procedure looks like this, and I can put it in a bash script to make updating a bit easier:

```bash
#!/usr/bin/env bash

cd /opt/myapp73k

# update from master
/usr/bin/git pull 73k master

# fetch prod deps & compile
/usr/bin/mix deps.get --only prod
MIX_ENV=prod /usr/bin/mix compile

# perform any migrations
MIX_ENV=prod /usr/bin/mix ecto.migrate

# update node packages via package-lock.json
/usr/bin/npm --prefix /opt/myapp73k/assets/ ci

# rebuild static assets:
rm -rf /opt/myapp73k/priv/static/*
/usr/bin/npm --prefix /opt/myapp73k/assets/ run deploy
MIX_ENV=prod /usr/bin/mix phx.digest

# rebuild release
MIX_ENV=prod /usr/bin/mix release --overwrite

# restart service
sudo /bin/systemctl restart myapp73k.service
```

### sudo permissions

To allow the user that's running the script to invoke `sudo` we need to give it explicit permission, e.g. by placing the following in a file like `/etc/sudoers.d/deploy_hooks`:

```bash
git  ALL=(runuser) NOPASSWD: /home/runuser/deploy_hooks/deploy-myapp73k.sh
runuser ALL= NOPASSWD: /bin/systemctl restart myapp73k.service
```

The first line allows the user `git` to run the script `/home/runuser/deploy_hooks/deploy-myapp73k.sh` *as the user* with username `runuser` -- and without requiring a password. Permissions should only allow the `runuser` accoutn to modify the script, so someone with access to the `git` account can't modify it to make it run something else.

The second line allows the user `runuser` to run *only* the command `/bin/systemctl restart myapp73k.service` without a password. Doing anything else with sudo will still ask for a password.

What this enables is that a git post-receive hook, running as user `git`, can call the deploy script, which runs as user `runuser` and performs the app update, which can finish by calling `systemctl restart`{:.lang-bash}

### gitea post-receive hook content

For git to run the deployment script after the repository receives a new commit, we set a git hook. But I want to be able to commit development branches to the repository without those commits getting deployed, so I want the hook to do nothing unless it's a commit to the master branch (could be any other branch, say "prod")

My hook looks something like this:

```bash
#!/usr/bin/env bash
while read oldrev newrev refname
do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    if [ "master" = "$branch" ]; then
        sudo -u runuser /home/runuser/deploy_hooks/deploy-myapp73k.sh
    fi
done
```

Here we can see the hook checks the branch first, and if master, runs `sudo -u runuser`{:.lang-bash} to run the script as user `runuser`

### elixir phoenix release systemd unit

That should just about do it, but as an extra note, here's the elixir phoenix release systemd unit:

```systemd
[Unit]
Description=MyApp73k service
After=local-fs.target network.target

[Service]
Type=simple
User=runuser
Group=runuser
WorkingDirectory=/opt/myapp/_build/prod/rel/myapp73k
ExecStart=/opt/myapp73k/_build/prod/rel/myapp73k/bin/myapp73k start
ExecStop=/opt/myapp73k/_build/prod/rel/myapp73k/bin/myapp73k stop
#EnvironmentFile=/etc/default/myApp.env
Environment=LANG=en_US.utf8
Environment=MIX_ENV=prod
Environment=PORT=4000
LimitNOFILE=65535
UMask=0027
SyslogIdentifier=myapp73k
Restart=always

[Install]
WantedBy=multi-user.target
```

I hope this is helpful to someone --- most of all my future self!
