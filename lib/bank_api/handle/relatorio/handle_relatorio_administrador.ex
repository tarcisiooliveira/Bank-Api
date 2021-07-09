defmodule BankApi.Handle.Report.HandleReportAdministrador do
  alias BankApi.Schemas.{Transaction, Account, Operation}
  alias BankApi.Repo
  import Ecto.Query

  def account_valida?(id_account) do
    case Repo.get_by(Account, id: id_account) do
      %Account{} -> true
      _ -> false
    end
  end

  def report(
        %{
          "periodo_inicial" => periodo_inicial,
          "periodo_final" => periodo_final,
          "from_account_id" => from_account_id,
          "to_account_id" => to_account_id,
          "Operation" => Operation
        } = _params
      ) do
    case account_valida?(from_account_id) &&
           account_valida?(to_account_id) &&
           validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transaction,
            join: o in Operation,
            on: o.id == t.operation_id,
            where:
              o.operation_name == ^Operation and
                t.to_account_id == ^to_account_id and
                t.from_account_id == ^from_account_id and
                t.inserted_at > ^periodo_inicial and
                t.inserted_at < ^periodo_final,
            select: t.value

        quantidade =
          Repo.all(query)
          |> Enum.count()

        case quantidade do
          0 ->
            return = %{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              mensagem: "Total durante determinado período entre duas accounts.",
              Operation: Operation,
              resultado: 0
            }

            {:ok, return}

          _ ->
            resultado = Repo.aggregate(query, :sum, :value)

            return = %{
              from_account_id: from_account_id,
              to_account_id: to_account_id,
              mensagem: "Total durante determinado período entre duas accounts.",
              Operation: Operation,
              resultado: resultado
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique Id da Account, Data ou Operção."
         }}
    end
  end

  def report(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "from_account_id" => from_account_id,
        "Operation" => Operation
      }) do
    case account_valida?(from_account_id) &&
           validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transaction,
            join: c in Account,
            join: o in Operation,
            on: o.id == t.operation_id,
            on: t.from_account_id == c.id,
            where:
              t.from_account_id == ^from_account_id and t.inserted_at >= ^periodo_inicial and
                t.inserted_at <= ^periodo_final and o.operation_name == ^Operation,
            select: t.value

        quantidade =
          Repo.all(query)
          |> Enum.count()

        case quantidade do
          0 ->
            return = %{
              from_account_id: from_account_id,
              mensagem: "Total durante determinado período por determinada Account.",
              Operation: Operation,
              resultado: 0
            }

            {:ok, return}

          _ ->
            resultado = Repo.aggregate(query, :sum, :value)

            return = %{
              from_account_id: from_account_id,
              mensagem: "Total durante determinado período por determinada Account.",
              Operation: Operation,
              resultado: resultado
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique Id da Account, Data ou Operção."
         }}
    end
  end

  def report(%{
        "periodo_inicial" => periodo_inicial,
        "periodo_final" => periodo_final,
        "Operation" => Operation
      }) do
    case validar_data(periodo_inicial) &&
           validar_data(periodo_final) do
      true ->
        query =
          from t in Transaction,
            join: o in Operation,
            on: o.id == t.operation_id,
            where:
              t.inserted_at >= ^periodo_inicial and
                t.inserted_at <= ^periodo_final and
                o.operation_name == ^Operation,
            select: t.value

        quantidade =
          Repo.all(query)
          |> Enum.count()

        case quantidade do
          0 ->
            return = %{
              mensagem: "Total durante determinado período por todas accounts.",
              Operation: Operation,
              resultado: 0
            }

            {:ok, return}

          _ ->
            resultado = Repo.aggregate(query, :sum, :value)

            return = %{
              mensagem: "Total durante determinado período por todas accounts.",
              Operation: Operation,
              resultado: resultado
            }

            {:ok, return}
        end

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique a Data ou Operção."
         }}
    end
  end

  def report(%{"from_account_id" => from_account_id, "Operation" => Operation}) do
    case account_valida?(from_account_id) do
      true ->
        query =
          from t in Transaction,
            join: c in Account,
            join: o in Operation,
            on: o.id == t.operation_id,
            on: t.from_account_id == c.id,
            where:
              o.operation_name == ^Operation and
                t.from_account_id == ^from_account_id,
            select: t.value

        resultado = Repo.aggregate(query, :sum, :value)

        return = %{
          mensagem: "Total realizado por determinada Account.",
          Operation: Operation,
          resultado: resultado
        }

        {:ok, return}

      false ->
        {:error,
         %{
           mensagem: "Dados inválidos. Verifique a Id da Account ou Operção."
         }}
    end
  end

  def report(%{"periodo" => "todo", "Operation" => Operation}) do
    query =
      from t in Transaction,
        join: o in Operation,
        on: t.operation_id == o.id,
        where: o.operation_name == ^Operation,
        select: [t.value]

    quantidade =
      Repo.all(query)
      |> Enum.count()

    case quantidade do
      0 ->
        return = %{
          mensagem: "Total durante todo o período",
          Operation: Operation,
          resultado: 0
        }

        {:ok, return}

      _ ->
        resultado = Repo.aggregate(query, :sum, :value)

        return = %{
          mensagem: "Total durante todo o período",
          Operation: Operation,
          resultado: resultado
        }

        {:ok, return}
    end
  end

  defp validar_data(data) do
    case NaiveDateTime.from_iso8601(data) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
