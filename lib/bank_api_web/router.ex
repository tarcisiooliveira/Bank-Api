defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  # use Plug.ErrorHandler
  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authAdmin do
    plug(BankApiWeb.Auth.PipelineAdmin)
  end

  pipeline :authUser do
    plug(BankApiWeb.Auth.PipelineUser)
  end

  scope "/", BankApiWeb do
    pipe_through(:api)
  end

  scope "/api/admin", BankApiWeb do
    pipe_through(:api)

    post("/sign_in", AdminController, :sign_in)
  end

  scope "/api/admin", BankApiWeb do
    pipe_through([:api, :authAdmin])

    post("/sign_up", AdminController, :sign_up)
    post("/report", ReportController, :report)
  end

  scope "/api/users", BankApiWeb do
    pipe_through(:api)

    post("/sign_in", UserController, :sign_in)
    post("/sign_up", UserController, :sign_up)
  end

  scope "/api/users", BankApiWeb do
    pipe_through([:api, :authUser])

    get("/user", UserController, :show)
    get("/transactions", TransactionController, :show)
    post("/transactions/transfer", TransactionController, :transfer)
    post("/transactions/withdraw", TransactionController, :withdraw)
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:fetch_session, :protect_from_forgery])
      live_dashboard("/dashboard", metrics: BankApiWeb.Telemetry)
    end
  end
end
