defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """
  use ExMachina.Ecto, repo: BankApi.Repo

  alias BankApi.Schemas.{Usuario, TipoConta, Operacao, Conta, Transacao, Admin}

  def usuario_factory do
    %Usuario{
      nome: "Tarcisio",
      email: sequence(:email, &"tarcisio#{&1}@gmail.com", start_at: 1000),
      password: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def admin_factory do
    %Admin{
      email: "tarcisio@admin.com",
      password: "123456",
      password_confirmation: "123456",
      password_hash: Bcrypt.hash_pwd_salt("123456")
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
      usuario_id: 0,
      tipo_conta_id: 0
    }
  end

  def tipo_conta_factory do
    %TipoConta{
      nome_tipo_conta: "Poupança Digital"
    }
  end

  def transacao_factory do
    %Transacao{
      conta_origem_id: 0,
      conta_destino_id: 0,
      operacao_id: 0,
      valor: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end

  def transacao_saque_factory do
    %Transacao{
      conta_origem_id: 0,
      operacao_id: 0,
      valor: 200_000,
      inserted_at: DateTime.utc_now()
    }
  end
  def transacao_pagamento_factory do
    %Transacao{
      conta_origem_id: 0,
      operacao_id: 0,
      valor: 0,
      inserted_at: DateTime.utc_now()
    }
  end
end
