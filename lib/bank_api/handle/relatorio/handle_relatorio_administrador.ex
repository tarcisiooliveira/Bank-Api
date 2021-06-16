defmodule BankApi.Handle.Relatorio.HandleRelatorioAdministrador do
  alias BankApi.Schemas.{Transacao, Usuario, Conta}
  alias BankApi.Repo
  import Ecto.Query

  def saque(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "email" => email
      }) do
    query =
      from t in Transacao,
        join: c in Conta,
        join: u in Usuario,
        on: t.conta_origem_id == c.id,
        on: c.usuario_id == u.id,
        where:
          u.email == ^email and t.inserted_at >= ^periodo_inicial and
            t.inserted_at <= ^periodo_final,
        select: t.valor

    resultado = Repo.aggregate(query, :sum, :valor)

    retorno = %{
      email: email,
      mensagem: "Total de saque durante determinado período por determinado usuario.",
      resultado: resultado
    }

    {:ok, retorno}
  end

  def saque(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final
      }) do
    query =
      from t in Transacao,
        join: c in Conta,
        on: t.conta_origem_id == c.id,
        where:
          t.inserted_at >= ^periodo_inicial and
            t.inserted_at <= ^periodo_final,
        select: t.valor

    resultado = Repo.aggregate(query, :sum, :valor)

    retorno = %{
      mensagem: "Total de saque durante determinado período por todos usuários.",
      resultado: resultado
    }

    {:ok, retorno}
  end

  def saque(%{"email" => email}) do
    query =
      from t in Transacao,
        join: c in Conta,
        join: u in Usuario,
        on: t.conta_origem_id == c.id,
        on: c.usuario_id == u.id,
        where: u.email == ^email,
        select: [t.valor]

    resultado = Repo.aggregate(query, :sum, :valor)

    retorno = %{
      mensagem: "Total de saque realizado por determinado email",
      resultado: resultado
    }

    {:ok, retorno}
  end

  def saque(%{"periodo" => "todo"}) do
    resultado = Repo.aggregate(Transacao, :sum, :valor)

    retorno = %{
      mensagem: "Total de saque durante todo o período",
      resultado: resultado
    }

    {:ok, retorno}
  end
end
