defmodule MessageSaverWeb.PageController do
  use MessageSaverWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
