defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Schemas.{Usuario, TipoConta, Operacao}

  def usuario_factory do
    %Usuario{
      nome: "Tarcisio",
      email: "tarcisiooliveira@pm.me",
      password: "123456",
      password_hash: Argon2.hash_pwd_salt("123456")
    }
  end

  def operacao_factory do
    %Operacao{
      nome_operacao: "Pagamento"
    }
  end

  def tipo_conta_factory do
    %TipoConta{
      nome_tipo_conta: "Poupança Digital"
    }
  end

  # def transacao_factory do
  #   %Transacao{
  #     conta_origem_id: insert(:usuario),
  #     conta_destino_id: insert(:usuario, nome: "Tarcisio2", email: "tarcisio2@tarcisio.com"),
  #     operacao_id: insert(:operacao, nome_operacao: "Transferência"),
  #     valor: 200_000
  #   }
  # end
end
