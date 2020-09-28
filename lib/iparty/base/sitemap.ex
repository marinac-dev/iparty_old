defmodule Iparty.Base.Sitemap do
  @base_url "https://www.iparty.rs"
  @sitemap_start ~s(<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n)
  @sitemap_end "\n</urlset>"

  def init() do
    routes =
      IpartyWeb.Router.__routes__()
      |> Enum.filter(&(&1.verb == :get))
      |> Enum.filter(&scope(&1.pipe_through))
      |> Enum.map(& &1.path)

    sitemap = @sitemap_start <> make_paths(routes) <> @sitemap_end
    File.write!(sitemap_path(), sitemap)
  end

  def make_paths(paths) do
    paths
    |> Enum.map(&~s(<url>\n\t<loc>#{@base_url}#{&1}</loc>\n</url>))
    |> Enum.join("\n")
  end

  def sitemap_path(), do: "assets/static/sitemap.xml"

  defp scope([:browser]), do: true
  defp scope([:browser, :redirect_if_user_is_authenticated]), do: true
  defp scope(_), do: false
end

# Run at compile time
require Logger
Logger.debug("Hehe compile time goes brrr")
Iparty.Base.Sitemap.init()
