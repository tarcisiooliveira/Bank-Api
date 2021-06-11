defmodule BankApiWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :bank_api

  #a ordem influencia na verificação Verificar o Cabeçalho, autenticação e carregamento dos recursos
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
