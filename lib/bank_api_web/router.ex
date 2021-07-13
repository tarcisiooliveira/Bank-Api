defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug BankApiWeb.Auth.Pipeline
  end

  scope "/", BankApiWeb do
    pipe_through(:api)
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)
    post "/sign_in", SignController, :sign_in
    post "/sign_up", SignController, :sign_up
  end

  scope "/api/report", BankApiWeb do
    pipe_through([:api, :auth])
    get "/payment", Report.ReportController, :payment
    get "/withdraw", Report.ReportController, :withdraw
    get "/transfer", Report.ReportController, :transfer
    get "/report", Report.ReportController, :report
  end

  scope "/api", BankApiWeb do
    pipe_through([:api, :auth])

    resources("/admin", Admin.AdminController, only: [:new, :show, :delete, :update, :index, :create])

    resources("/user", UserController, only: [:new, :show, :delete, :update, :index, :create])

    resources("/accounttype", AccountTypeController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/operation", OperationController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/account", AccountController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/transaction", TransactionController,
      only: [:new, :show, :delete, :update, :create]
    )
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:fetch_session, :protect_from_forgery])
      live_dashboard("/dashboard", metrics: BankApiWeb.Telemetry)
    end
  end
end
