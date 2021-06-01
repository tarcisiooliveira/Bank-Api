defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Schemas.{Usuario, TipoConta}

  def usuario_factory do
    %Usuario{
      nome: "Tarcisio",
      email: "tarcisiooliveira@pm.me",
      password: "123456",
      password_hash: Argon2.hash_pwd_salt("123456")
    }
  end

  # def conta_factory do
  #   %Conta{
  #     saldo_conta: 100_000,
  #     usuario_id: build(:usuario),
  #     tipo_conta_id: build(:tipo_conta)
  #   }
  # end

  def tipo_conta_factory do
    %TipoConta{
      nome_tipo_conta: "Poupança"
    }
  end

  # def operacao_factory do
  #   %Operacao{
  #     nome_operacao: "Transferencia"
  #   }
  # end
end
