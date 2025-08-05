defmodule CopilotWeb.Router do
  use CopilotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug CopilotWeb.Plugs.UserInfo
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CopilotWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    # In development, this plug will mock the authentication header
    # that would normally be injected by the API Gateway.
    if Application.compile_env(:copilot, :dev_routes) do
      plug CopilotWeb.Plugs.DevAuth
    end

    # This plug extracts the user info from the header (real or mocked)
    # and puts it in conn.assigns.
    plug CopilotWeb.Plugs.UserInfo
  end

  scope "/", CopilotWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/info", InfoLive, :index
  end

  scope "/api", CopilotWeb do
    pipe_through :api

    # Example of a protected route that requires any authenticated user
    pipeline :protected do
      plug CopilotWeb.Plugs.EnsureAuthenticated
    end

    # Example of a route that requires a user with the "developer" role
    pipeline :developer_only do
      plug CopilotWeb.Plugs.EnsureAuthenticated
      plug CopilotWeb.Plugs.Authorization, "developer"
    end

    # Example of a route that requires a user with the "admin" role
    pipeline :admin_only do
      plug CopilotWeb.Plugs.EnsureAuthenticated
      plug CopilotWeb.Plugs.Authorization, "admin"
    end

    scope "/me" do
      pipe_through :protected
      get "/", UserController, :show
      put "/", UserController, :update
      delete "/", UserController, :delete
    end

    # scope "/admin", CopilotWeb do
    #   pipe_through :admin_only
    #   # Add admin-only routes here, for example:
    #   # get "/dashboard", AdminDashboardController, :show
    # end

    resources "/briefs", BriefController, except: [:new, :edit]
    resources "/contacts", ContactController, except: [:new, :edit]
    resources "/ai_analyses", AIAnalysisController, except: [:new, :edit]
    resources "/cost_estimates", CostEstimateController, except: [:new, :edit]

    scope "/" do
      pipe_through :developer_only
      resources "/customers", CustomerController, except: [:new, :edit]
      put "/users/:id/role", UserController, :update_role
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:copilot, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: CopilotWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

    # Now the catch all must always be at the bottom, add this snippet
  scope "/", CopilotWeb do
    pipe_through :api
    match :*, "/*path", CatchAllController, :match_invalid_routes
  end
end
