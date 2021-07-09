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
    post "/sign_in", SignInController, :sign_in
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)
    post "/sign_in", SignInController, :sign_in
  end

  scope "/api/reports", BankApiWeb do
    pipe_through([:api, :auth])
    post "/payments", ReportController, :payment
    post "/saques", ReportController, :withdraw
    post "/transferencias", ReportController, :transfer
  end

  scope "/api", BankApiWeb do
    pipe_through([:api, :auth])

    resources("/admins", AdminController, only: [:new, :show, :delete, :update, :index, :create])

    resources("/Users", UserController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/accounttype", AccountTypeController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/operations", OperationController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/accounts", AccountController, only: [:new, :show, :delete, :update, :index, :create])

    resources("/transactions", TransacaoController, only: [:new, :show, :delete, :update, :create])
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
