defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Schemas.{Usuario, TipoConta, Operacao, Conta}

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
      nome_operacao: "Transferência"
    }
  end

  def conta_factory do
    %Conta{
      saldo_conta: 100_000,
      usuario_id: insert(:usuario, email: "teste@insert.com"),
      tipo_conta_id: insert(:tipo_conta, nome_tipo_conta: "Nome Ficticio")
    }
  end

  def tipo_conta_factory do
    %TipoConta{
      nome_tipo_conta: "Poupança Digital"
    }
  end

  # def transacao_factory do
  #   %Transacao{
  #     conta_origem_id: insert(:conta),
  #     conta_destino_id: insert(:conta),
  #     operacao_id: insert(:operacao, nome_operacao: "Transferência"),
  #     valor: 200_000
  #   }
  # end
end
