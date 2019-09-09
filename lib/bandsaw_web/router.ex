defmodule Bandsaw.Web.Router do
  use Bandsaw.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {Bandsaw.Web.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Bandsaw.Web.ProjectPlug
  end

  scope "/api/v1", Bandsaw.Web do
    pipe_through :api

    post "/logs", LogController, :write
  end

  scope "/", Bandsaw.Web do
    pipe_through :browser

    live "/projects/:id/environments/new",  EnvironmentLive.New
    live "/projects/:id/environments",      EnvironmentLive.Index
    live "/projects/:id/edit",              ProjectLive.Edit
    live "/projects/new",                   ProjectLive.New

    live "/environments/:id/edit",          EnvironmentLive.Edit
    live "/environments/:id/entries",       LogEntryLive.Index

    live "/",                               ProjectLive.Index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bandsaw.Web do
  #   pipe_through :api
  # end
end
