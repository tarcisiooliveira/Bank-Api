defmodule BankApiWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :bank_api

  @moduledoc """
    Plug de validação de acesso a api. Precisa passar token válido.
  """
  # a ordem influencia na verificação Verificar o Cabeçalho, autenticação e carregamento dos recursos
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
