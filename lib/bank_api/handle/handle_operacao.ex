defmodule BankApi.Handle.HandleOperacao do
  alias BankApi.Schemas.Operacao
  alias BankApi.Repo

  @moduledoc """
  Modulo de manipulação de dados Operação através do Repo
  """
  def get(id) do
    case Repo.get_by(Operacao, id: id) do
      nil -> {:error, "ID Inválido"}
      operacao -> {:ok, operacao}
    end
  end

  def create(%{"nome_operacao" => _nome_operacao} = params) do
    case Operacao.changeset(params) |> Repo.insert() do
      {:error, changeset} -> {:error, changeset}
      {:ok, trainer} -> {:ok, trainer}
    end
  end

  def update(id, %{nome_operacao: nome_operacao} = _params) do
    case Repo.get_by(Operacao, id: id) do
      nil ->
        {:error, "ID Inválido ou inexistente"}

      operacao ->
        Operacao.update_changeset(operacao, %{nome_operacao: nome_operacao})
        |> Repo.update()
    end
  end

  def delete(id) do
    case Repo.get_by(Operacao, id: id) do
      nil -> {:error, "ID Inválido ou inexistente"}
      operacao -> Repo.delete(operacao)
    end
  end
end
