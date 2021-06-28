defmodule BankApi.Handle.HandleTransacao do
  alias BankApi.Multi.Transacao, as: MultiTransacao
  alias BankApi.Handle.Repo.Transacao, as: HandleTransacaoRepo

  @moduledoc """
  Modulo de manipulação de dados Transação através do Repo
  """
  def get(id) do
    case HandleTransacaoRepo.fetch_transacao(id) do
      nil -> {:error, "ID inválido."}
      transacao -> {:ok, transacao}
    end
  end

  def create(
        %{
          "conta_origem_id" => _conta_origem_id,
          "conta_destino_id" => _conta_destino_id,
          "operacao_id" => _operacao_id,
          "valor" => _valor
        } = params
      ) do
    params
    |> MultiTransacao.create()
  end

  def create(params) do
    params
    |> MultiTransacao.create()
  end

  def delete(id) do
    case HandleTransacaoRepo.fetch_transacao(id) do
      nil -> {:error, "ID inválido."}
      transacao -> HandleTransacaoRepo.delete(transacao)
    end
  end

  # def update(id, %{valor: valor}) do
  #   case Repo.get_by(Transacao, id: id) do
  #     nil ->
  #       {:error, "ID inválido"}

  #     transacao ->
  #       Transacao.update_changeset(transacao, %{valor: valor})
  #       |> Repo.update()
  #   end
  # end
end
