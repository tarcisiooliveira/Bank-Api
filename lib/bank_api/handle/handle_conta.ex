defmodule BankApi.Handle.HandleConta do
  alias BankApi.Multi.Conta, as: MultiConta
  alias BankApi.Handle.Repo.Conta, as: HandleRepoConta

  @moduledoc """
  Modulo de manipulação de dados Conta
  """
  def get(%{id: _id}=params) do
    case HandleRepoConta.fetch_account(params) do
      nil -> {:error, "ID Inválido ou inexistente."}
      conta -> {:ok, conta}
    end
  end

  def create(params) do
    params
    |> MultiConta.create()
  end

  def update(%{id: _id, saldo_conta: _saldo_conta} = params) do
    params
    |> MultiConta.update()
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiConta.delete()
  end
end
