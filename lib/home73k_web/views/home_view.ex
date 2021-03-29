defmodule Home73kWeb.HomeView do
  use Home73kWeb, :view

  def socials(conn) do
    [
      %{
        icon: "mdi-typewriter",
        url: "https://w.73k.us/",
        prof: false
      },
      %{icon: "mdi-rss", url: "https://w.73k.us/feed/", prof: false},
      %{
        icon: "mdi-linkedin",
        url: "https://www.linkedin.com/in/adampiontek/",
        prof: true
      },
      %{icon: "mdi-github", url: "https://github.com/apiontek", prof: true},
      %{icon: "gitea", url: "https://73k.us/git/adam", prof: true},
      %{
        icon: "mdi-key-variant",
        url: Routes.static_path(conn, "/DF185CEE29A3D443_public_key.asc"),
        prof: true
      },
      %{
        icon: "mdi-goodreads",
        url: "https://www.goodreads.com/user/show/2450014-adam-piontek",
        prof: false
      },
      %{icon: "mdi-twitter", url: "https://twitter.com/adampiontek", prof: false},
      %{icon: "mdi-facebook", url: "https://facebook.com/damek", prof: false},
      %{
        icon: "mdi-instagram",
        url: "https://www.instagram.com/adampiontek/",
        prof: false
      },
      %{
        icon: "mdi-steam",
        url: "https://steamcommunity.com/id/apiontek/",
        prof: false
      },
      %{
        icon: "mdi-discord",
        url: "https://discordapp.com/users/328583977629646848",
        prof: false
      }
    ]
  end

  def socials_prof(conn), do: Enum.filter(socials(conn), fn s -> s.prof end)

  def resume_qualifs,
    do: [
      "Programming (Powershell, Bash, Python, Javascript, Elixir)",
      "Windows deployment & support (SCCM, MDT, esoteric configuration)",
      "Application infrastructure planning & implementation (end-to-end)",
      "Quickly grasping inherited & new projects"
    ]

  def resume_experience do
    [
      %{
        employer: "Cleary Gottlieb Steen & Hamilton",
        positions: [
          %{title: "End User Systems Engineer", start: "Jan 2021", end: "Present"},
          %{title: "End User Systems Analyst", start: "Feb 2019", end: "Dec 2020"},
          %{title: "Service Desk Analyst", start: "Jun 2014", end: "Jan 2019"}
        ]
      },
      %{
        employer: "Practising Law Institute",
        positions: [
          %{title: "Service Desk Analyst", start: "May 2010", end: "May 2014"}
        ]
      }
    ]
  end
end
