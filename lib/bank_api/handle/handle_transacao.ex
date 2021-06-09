defmodule BankApi.Handle.HandleTransacao do
  alias BankApi.{Repo, Schemas.Transacao}

  @moduledoc """
  Modulo de manipulação de dados Transação através do Repo
  """
  def get(id) do
    case Repo.get_by(Transacao, id: id) do
      nil -> {:error, "ID inválido"}
      transacao -> {:ok, transacao}
    end
  end

  def create(params) do
    params
    |> Transacao.changeset()
    |> Repo.insert()
  end

  def delete(id) do
    case Repo.get_by(Transacao, id: id) do
      nil -> {:error, "ID inválido"}
      transacao -> Repo.delete(transacao)
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
