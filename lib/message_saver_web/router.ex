defmodule MessageSaverWeb.Router do
  use MessageSaverWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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

  scope "/", MessageSaverWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MessageSaverWeb do
  #   pipe_through :api
  # end
end
