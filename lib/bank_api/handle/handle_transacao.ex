defmodule BankApi.Handle.HandleTransacao do
  alias BankApi.Multi.Transacao, as: MultiTransacao
  alias BankApi.Handle.Repo.Transacao, as: HandleTransacaoRepo

  @moduledoc """
  Modulo de manipulação de dados Transação através do Repo
  """
  def get(%{id: id}) do
    case HandleTransacaoRepo.fetch_transaction(id) do
      nil -> {:error, "ID inválido."}
      transacao -> {:ok, transacao}
    end
  end

  def create(%{
        conta_origem_id: conta_origem_id,
        conta_destino_id: conta_destino_id,
        operacao_id: operacao_id,
        valor: valor
      }) do
    %{
      conta_origem_id: conta_origem_id,
      conta_destino_id: conta_destino_id,
      operacao_id: operacao_id,
      valor: valor
    }
    |> MultiTransacao.create()
  end

  def create(%{
        conta_origem_id: conta_origem_id,
        operacao_id: operacao_id,
        valor: valor
      }) do
    %{
      conta_origem_id: conta_origem_id,
      operacao_id: operacao_id,
      valor: valor
    }
    |> MultiTransacao.create()
  end

  def delete(%{id: _id} = params) do
    params
    |> MultiTransacao.delete()
  end
end
