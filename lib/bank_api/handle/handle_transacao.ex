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

  def create(
        %{
          "conta_origem_id" => conta_origem_id,
          "conta_destino_id1" => conta_destino_id1,
          "conta_destino_id2" => conta_destino_id2,
          "operacao_id" => operacao_id,
          "valor" => _valor,
          "lista" => lista
        } = params
      ) do
    # transacao1 = %{
    #   "conta_origem_id" => conta_origem_id,
    #   "conta_destino_id" => conta_destino_id1,
    #   "operacao_id" => operacao_id,
    #   "valor" => Enum.at(lista, 0)
    # }
    # transacao2 = %{
    #   "conta_origem_id" => conta_origem_id,
    #   "conta_destino_id" => conta_destino_id2,
    #   "operacao_id" => operacao_id,
    #   "valor" => Enum.at(lista, 1)
    # }

    # conta
    params
    |> Transacao.changeset()
    |> Repo.insert()
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
