defmodule BankApiWeb.Auth.PipelineUser do
  @moduledoc """
    Plug de validação de acesso a api. Precisa passar token válido.
  """

  use Guardian.Plug.Pipeline, otp_app: :bank_api

  # a ordem influencia na verificação Verificar o Cabeçalho, autenticação e carregamento dos recursos
  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
