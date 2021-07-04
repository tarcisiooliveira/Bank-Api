defmodule BankApi.Handle.HandleOperacao do
  alias BankApi.Schemas.Operacao
  alias BankApi.Repo
  alias BankApi.Multi.Operacao, as: MultiOperation

  @moduledoc """
  Modulo de manipulação de dados Operação através do Repo
  """
  def get(%{id: id}) do
    case Repo.get_by(Operacao, id: id) do
      nil -> {:error, "ID Inválido ou inexistente."}
      operacao -> {:ok, operacao}
    end
  end

  def create(%{nome_operacao: _nome_operacao} = params) do
    MultiOperation.create(params)
  end

  def update(%{id: _id, nome_operacao: _nome_operacao} = params) do
    MultiOperation.update(params)
  end

  def delete(%{id: _id} = params) do
    MultiOperation.delete(params)
  end
end
