defmodule BankApi.Handle.Relatorio.HandleRelatorioAdministrador do
  alias BankApi.Schemas.{Transacao, Usuario, Conta, Operacao}
  alias BankApi.Repo
  import Ecto.Query

  def relatorio(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "email" => email,
        "operacao" => operacao
      }) do
    case EmailChecker.valid?(email) && validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transacao,
            join: c in Conta,
            join: u in Usuario,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            on: t.conta_origem_id == c.id,
            on: c.usuario_id == u.id,
            where:
              u.email == ^email and t.inserted_at >= ^periodo_inicial and
                t.inserted_at <= ^periodo_final and o.nome_operacao == ^operacao,
            select: t.valor

        resultado = Repo.aggregate(query, :sum, :valor)

        retorno = %{
          email: email,
          mensagem: "Total de saque durante determinado período por determinado usuario.",
          operacao: operacao,
          resultado: resultado
        }

        {:ok, retorno}

      false ->
        {:error,
         %{
           mensagem: "Email ou Data inválido."
         }}
    end
  end

  def relatorio(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "operacao" => operacao
      }) do
    case validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transacao,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            where:
              t.inserted_at >= ^periodo_inicial and
                t.inserted_at <= ^periodo_final and
                o.nome_operacao == ^operacao,
            select: t.valor

        resultado = Repo.aggregate(query, :sum, :valor)

        retorno = %{
          mensagem: "Total de saque durante determinado período por todos usuários.",
          operacao: operacao,
          resultado: resultado
        }

        {:ok, retorno}

      false ->
        {:error,
         %{
           mensagem: "Email ou Data inválido."
         }}
    end
  end

  def relatorio(%{"email" => email, "operacao" => operacao}) do
    case EmailChecker.valid?(email) do
      true ->
        query =
          from t in Transacao,
            join: c in Conta,
            join: u in Usuario,
            join: o in Operacao,
            on: o.id == t.operacao_id,
            on: t.conta_origem_id == c.id,
            on: c.usuario_id == u.id,
            where: u.email == ^email and o.nome_operacao == ^operacao,
            select: [t.valor, u.email]

        resultado = Repo.aggregate(query, :sum, :valor)

        retorno = %{
          mensagem: "Total realizado por determinado email",
          operacao: operacao,
          resultado: resultado
        }

        {:ok, retorno}

      false ->
        {:error,
         %{
           mensagem: "Email ou Data inválido."
         }}
    end
  end

  def relatorio(%{"periodo" => "todo", "operacao" => operacao}) do
    query =
      from t in Transacao,
        join: o in Operacao,
        on: t.operacao_id == o.id,
        where: o.nome_operacao == ^operacao,
        select: [t.valor]

    resultado =
      Repo.aggregate(query, :sum, :valor)
      |> IO.inspect()

    retorno = %{
      mensagem: "Total durante todo o período",
      operacao: operacao,
      resultado: resultado
    }

    {:ok, retorno}
  end

  defp validar_data(data) do
    case NaiveDateTime.from_iso8601(data) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
