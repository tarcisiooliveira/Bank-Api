defmodule BankApi.Handle.HandleTipoConta do
  alias BankApi.{Repo, Schemas.TipoConta}

  def get(id) do
    case Repo.get_by(TipoConta, id: id) do
      nil -> {:error, "ID Inválido"}
      tipo_conta -> {:ok, tipo_conta}
    end
  end

  def delete(id) do
    case Repo.get_by!(TipoConta, id: id) do
      nil -> {:error, "ID Inválido"}
      tipo_conta -> Repo.delete(tipo_conta)
    end
  end

  def create(nome_tipo_conta) do
    nome_tipo_conta
    |> TipoConta.changeset()
    |> Repo.insert()
  end

  def update(id, %{nome_tipo_conta: nome_tipo_conta}) do
    case Repo.get_by(TipoConta, id: id) do
      nil -> %{error: "ID Inválido"}
      tipo_conta -> TipoConta.changeset(tipo_conta, %{nome_tipo_conta: nome_tipo_conta})
      |> Repo.update()
    end

  end
end
