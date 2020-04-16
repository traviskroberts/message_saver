defmodule MessageSaverWeb.Router do
  use MessageSaverWeb, :router

  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    scope "/api", MessageSaverWeb.Api do
      post "/actions", ActionsController, :create
      post "/command", ActionsController, :command
    end
  end

  pipeline :admins_only do
    plug :basic_auth, username: System.get_env("DASHBOARD_USERNAME"), password: System.get_env("DASHBOARD_PASSWORD")
  end

  scope "/", MessageSaverWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/dashboard"
  end

  # Other scopes may use custom stacks.
  # scope "/api", MessageSaverWeb do
  #   pipe_through :api
  # end
end
