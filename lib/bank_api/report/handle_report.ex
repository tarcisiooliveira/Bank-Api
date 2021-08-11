defmodule BankApi.Report.HandleReport do
  @moduledoc """
    This Module generate manipulate all Report request than return result.
  """

  alias BankApi.Transactions.Schemas.Transaction
  alias BankApi.Repo
  import Ecto.Query

  def report(%{"period" => "all"} = params) when params == %{"period" => "all"} do
    query =
      from t in Transaction,
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        {:ok, result: 0}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        {:ok, result: result}
    end
  end

  def report(%{"period" => "today"} = params) when params == %{"period" => "today"} do
    day =
      Date.utc_today()
      |> to_string

    {:ok, start_day} =
      (day <> " 00:00:00")
      |> NaiveDateTime.from_iso8601()

    {:ok, end_day} =
      (day <> " 23:59:59")
      |> NaiveDateTime.from_iso8601()

    query =
      from t in Transaction,
        where:
          fragment(
            "? BETWEEN ? AND ?",
            t.inserted_at,
            ^start_day,
            ^end_day
          )

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        {:ok, result: 0}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        {:ok, result: result}
    end
  end

  def report(%{"period" => "month"} = params) when params == %{"period" => "month"} do
    {:ok, start_month} =
      Date.utc_today()
      |> Date.beginning_of_month()
      |> Date.to_string()
      |> agregate_start()
      |> NaiveDateTime.from_iso8601()

    {:ok, next_month} =
      NaiveDateTime.utc_now()
      |> Date.end_of_month()
      |> Date.to_string()
      |> agregate_end
      |> NaiveDateTime.from_iso8601()

    query =
      from t in Transaction,
        where:
          fragment(
            "? BETWEEN ? AND ?",
            t.inserted_at,
            ^start_month,
            ^next_month
          ),
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        {:ok, result: 0}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        {:ok, result: result}
    end
  end

  def report(%{"period" => "month", "month" => month} = params)
      when params == %{"period" => "month", "month" => month} do
    data = NaiveDateTime.utc_now()

    {:ok, start_month} =
      NaiveDateTime.new(data.year, String.to_integer(month), 01, 00, 00, 00, 000_000)

    {:ok, next_month} =
      start_month
      |> Date.end_of_month()
      |> to_string()
      |> agregate_end()
      |> NaiveDateTime.from_iso8601()

    query =
      from t in Transaction,
        where:
          fragment(
            "? BETWEEN ? AND ?",
            t.inserted_at,
            ^start_month,
            ^next_month
          ),
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        {:ok, result: 0}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        {:ok, result: result}
    end
  end

  def report(%{"period" => "year", "year" => year}) do
    {:ok, start_day} = NaiveDateTime.from_iso8601(year <> "-01-01 00:00:00")

    {:ok, end_day} = NaiveDateTime.from_iso8601(year <> "-12-31 23:59:59")

    query =
      from t in Transaction,
        where:
          fragment(
            "? BETWEEN ? AND ?",
            t.inserted_at,
            ^start_day,
            ^end_day
          ),
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        {:ok, result: 0}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        {:ok, result: result}
    end
  end

  def report(params) when params == %{"period" => "year"} do
    date_time = DateTime.utc_now().year |> to_string()

    {:ok, start_day} = NaiveDateTime.from_iso8601(date_time <> "-01-01 00:00:00")

    {:ok, end_day} = NaiveDateTime.from_iso8601(date_time <> "-12-31 23:59:59")

    query =
      from t in Transaction,
        where:
          fragment(
            "? BETWEEN ? AND ?",
            t.inserted_at,
            ^start_day,
            ^end_day
          ),
        select: t.value

    quantity =
      Repo.all(query)
      |> Enum.count()

    case quantity do
      0 ->
        {:ok, result: 0}

      _ ->
        result = Repo.aggregate(query, :sum, :value)

        {:ok, result: result}
    end
  end

  def report(_) do
    {:error, :invalid_parameters}
  end

  defp agregate_start(string) do
    string <> " 00:00:00"
  end

  defp agregate_end(string) do
    string <> " 23:59:59"
  end
end
