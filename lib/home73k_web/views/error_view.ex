defmodule Home73kWeb.ErrorView do
  use Home73kWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("4" <> _rest, assigns), do: render("e40x.html", assigns)
  def render("5" <> _rest, assigns), do: render("e50x.html", assigns)
end
