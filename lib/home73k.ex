defmodule Home73k do
  @moduledoc """
  Home73k keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @app_vars Application.compile_env(:home73k, :app_global_vars, time_zone: "America/New_York")

  def app_vars, do: @app_vars
  def app_time_zone, do: @app_vars[:time_zone]
  def app_blog_content, do: @app_vars[:blog_content]
  def app_pygmentize_bin, do: @app_vars[:pygmentize_bin]
end
