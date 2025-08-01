defmodule CopilotApiWeb.Router do
  use CopilotApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]

    # In development, this plug will mock the authentication header
    # that would normally be injected by the API Gateway.
    if Application.compile_env(:copilot_api, :dev_routes) do
      plug CopilotApiWeb.Plugs.DevAuth
    end

    # This plug extracts the user info from the header (real or mocked)
    # and puts it in conn.assigns.
    plug CopilotApiWeb.Plugs.UserInfo
  end

  scope "/api", CopilotApiWeb do
    pipe_through :api

    # Example of a protected route that requires any authenticated user
    pipeline :protected do
      plug CopilotApiWeb.Plugs.EnsureAuthenticated
    end

    # Example of a route that requires a user with the "developer" role
    pipeline :developer_only do
      plug CopilotApiWeb.Plugs.EnsureAuthenticated
      plug CopilotApiWeb.Plugs.Authorization, "developer"
    end

    # Example of a route that requires a user with the "admin" role
    pipeline :admin_only do
      plug CopilotApiWeb.Plugs.EnsureAuthenticated
      plug CopilotApiWeb.Plugs.Authorization, "admin"
    end

    scope "/me" do
      pipe_through :developer_only
      get "/", UserController, :show
    end

    # scope "/admin", CopilotApiWeb do
    #   pipe_through :admin_only
    #   # Add admin-only routes here, for example:
    #   # get "/dashboard", AdminDashboardController, :show
    # end

    resources "/briefs", BriefController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:copilot_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: CopilotApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
