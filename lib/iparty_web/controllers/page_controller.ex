defmodule IpartyWeb.PageController do
  use IpartyWeb, :controller

  # NavBar menu
  def index(conn, _params), do: conn |> render("index.html")
  def iparty(conn, _params), do: conn |> render("iparty.html")
  def how_to(conn, _params), do: conn |> render("how-to.html")
  def tos(conn, _params), do: conn |> render("tos.html")
  def faq(conn, _params), do: conn |> render("faq.html")
  def about(conn, _params), do: conn |> render("about.html")
  def contact(conn, _params), do: conn |> render("contact.html")
  def privacy(conn, _params), do: conn |> render("privacy-policy.html")

  def profile(conn, _params), do: conn |> render("profile.html")
end
