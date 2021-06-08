defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # pipeline :auth do
  #   plug BankApiWeb.Auth.Pipeline
  # end

  scope "/", BankApiWeb do
    pipe_through(:api)
    get("/", WelcomeController, :index)
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)
    get("/", WelcomeController, :index)
    get("/instrucoes", WelcomeController, :index)

    resources("/usuarios", UsuariosController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/tipocontas", TipoContaController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/operacoes", OperacaoController,
      only: [:new, :show, :delete, :update, :index, :create]
    )

    resources("/contas", ContaController, only: [:new, :show, :delete, :update, :index, :create])
  end

  # scope "/api", BankApiWeb do
  #   pipe_through [:api, :auth]
  #   resources "/trainers", TrainersController, only: [:show, :delete, :update]

  #   resources "/trainer_pokemons", TrainerPokemonsController,
  #     only: [:create, :show, :delete, :update]
  # end

  # scope "/api", BankApiWeb do
  #   pipe_through :api
  # end

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
