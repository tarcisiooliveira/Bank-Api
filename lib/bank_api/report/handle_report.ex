defmodule BankApi.Report.HandleReport do
  @moduledoc """
    This Module generate manipulate all Report request than return result.
  """

  import Ecto.Query
  alias BankApi.Repo
  alias BankApi.Transactions.Schemas.Transaction

  @doc """
  Return report of all period

  ## Parameters

    `period` - Period of report
    `month` - Decimal number of month.
    `year` - Decimal number of year.

  ## Examples
      iex> report(%{"period" => "all"})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "today"})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "month"})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "month", "month" => 07})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "year"})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "year"})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "year", "year" => "2020"})
      {:ok, [result: %{withdraw: 0, transfer: 0}]}

      iex> report(%{"period" => "day", "day" => "2021-13-23"})
      {:error, :invalid_date}

  """
  def report(%{"period" => "all"} = params) when params == %{"period" => "all"} do
    query_withdraw =
      from t in Transaction,
        where: is_nil(t.to_account_id),
        select: t.value

    query_transfer =
      from t in Transaction,
        where: is_nil(t.to_account_id) == false,
        select: t.value

    quantity_withdraw =
      case Repo.aggregate(query_withdraw, :sum, :value) do
        nil -> 0
        result -> result
      end

    quantity_transfer =
      case Repo.aggregate(query_transfer, :sum, :value) do
        nil -> 0
        result -> result
      end

    result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}

    {:ok, result: result}
  end

  def report(%{"period" => "today"} = params) when params == %{"period" => "today"} do
    day = Date.utc_today()

    query_withdraw =
      from t in Transaction,
        where:
          fragment("date(date_trunc('day', ?))", t.inserted_at) == ^day and
            is_nil(t.to_account_id)

    query_transfer =
      from t in Transaction,
        where:
          fragment("date(date_trunc('day', ?))", t.inserted_at) == ^day and
            is_nil(t.to_account_id) == false

    quantity_withdraw =
      case Repo.aggregate(query_withdraw, :sum, :value) do
        nil -> 0
        result -> result
      end

    quantity_transfer =
      case Repo.aggregate(query_transfer, :sum, :value) do
        nil -> 0
        result -> result
      end

    result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}

    {:ok, result: result}
  end

  def report(%{"period" => "day", "day" => day} = params)
      when params == %{"period" => "day", "day" => day} do
    with {:ok, day} <- Date.from_iso8601(day) do
      query_withdraw =
        from t in Transaction,
          where:
            fragment("date(date_trunc('day', ?))", t.inserted_at) == ^day and
              is_nil(t.to_account_id),
          select: t.value

      query_transfer =
        from t in Transaction,
          where:
            fragment("date(date_trunc('day', ?))", t.inserted_at) == ^day and
              is_nil(t.to_account_id) == false,
          select: t.value

      quantity_withdraw =
        case Repo.aggregate(query_withdraw, :sum, :value) do
          nil -> 0
          result -> result
        end

      quantity_transfer =
        case Repo.aggregate(query_transfer, :sum, :value) do
          nil -> 0
          result -> result
        end

      result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}

      {:ok, result: result}
    end
  end

  def report(%{"period" => "month"} = params) when params == %{"period" => "month"} do
    query_withdraw =
      from t in Transaction,
        where:
          fragment("date(date_trunc('month', ?))", t.inserted_at) ==
            ^date_trunc(Date.utc_today(), :month) and is_nil(t.to_account_id),
        select: t.value

    query_transfer =
      from t in Transaction,
        where:
          fragment("date(date_trunc('month', ?))", t.inserted_at) ==
            ^date_trunc(Date.utc_today(), :month) and is_nil(t.to_account_id) == false,
        select: t.value

    quantity_withdraw =
      case Repo.aggregate(query_withdraw, :sum, :value) do
        nil -> 0
        result -> result
      end

    quantity_transfer =
      case Repo.aggregate(query_transfer, :sum, :value) do
        nil -> 0
        result -> result
      end

    result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}

    {:ok, result: result}
  end

  def report(%{"period" => "month", "month" => month} = params)
      when params == %{"period" => "month", "month" => month} do
    data = Date.utc_today()

    case "#{data.year}-#{month}-01" |> Date.from_iso8601() do
      {:ok, data} ->
        query_withdraw =
          from t in Transaction,
            where:
              fragment("date(date_trunc('month', ?))", t.inserted_at) == ^data and
                is_nil(t.to_account_id),
            select: t.value

        query_transfer =
          from t in Transaction,
            where:
              fragment("date(date_trunc('month', ?))", t.inserted_at) == ^data and
                is_nil(t.to_account_id) == false,
            select: t.value

        quantity_withdraw =
          case Repo.aggregate(query_withdraw, :sum, :value) do
            nil -> 0
            result -> result
          end

        quantity_transfer =
          case Repo.aggregate(query_transfer, :sum, :value) do
            nil -> 0
            result -> result
          end

        result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}

        {:ok, result: result}

      _ ->
        {:error, :invalid_date}
    end
  end

  def report(%{"period" => "year", "year" => year}) do
    year
    |> Decimal.new()
    |> Decimal.negative?()
    |> case do
      true ->
        {:error, :invalid_date}

      _ ->
        {:ok, newdata} = "#{year}-01-01" |> Date.from_iso8601()

        query_withdraw =
          from t in Transaction,
            where:
              fragment("date(date_trunc('year', ?))", t.inserted_at) == ^newdata and
                is_nil(t.to_account_id),
            select: t.value

        query_transfer =
          from t in Transaction,
            where:
              fragment("date(date_trunc('year', ?))", t.inserted_at) == ^newdata and
                is_nil(t.to_account_id) == false,
            select: t.value

        quantity_withdraw =
          case Repo.aggregate(query_withdraw, :sum, :value) do
            nil -> 0
            result -> result
          end

        quantity_transfer =
          case Repo.aggregate(query_transfer, :sum, :value) do
            nil -> 0
            result -> result
          end

        result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}

        {:ok, result: result}
    end
  end

  def report(params) when params == %{"period" => "year"} do
    query_withdraw =
      from t in Transaction,
        where:
          fragment("date(date_trunc('year', ?))", t.inserted_at) ==
            ^date_trunc(Date.utc_today(), :year) and
            is_nil(t.to_account_id),
        select: t.value

    query_transfer =
      from t in Transaction,
        where:
          fragment("date(date_trunc('year', ?))", t.inserted_at) ==
            ^date_trunc(Date.utc_today(), :year) and
            is_nil(t.to_account_id) == false,
        select: t.value

    quantity_withdraw =
      case Repo.aggregate(query_withdraw, :sum, :value) do
        nil -> 0
        result -> result
      end

    quantity_transfer =
      case Repo.aggregate(query_transfer, :sum, :value) do
        nil -> 0
        result -> result
      end

    result = %{withdraw: quantity_withdraw, transfer: quantity_transfer}
    {:ok, result: result}
  end

  def report(_) do
    {:error, :invalid_parameters}
  end

  def date_trunc(date, :month) do
    if date.month <= 9 do
      {:ok, date} = Date.from_iso8601("#{date.year}-0#{date.month}-01")
      date
    else
      {:ok, date} = Date.from_iso8601("#{date.year}-#{date.month}-01")
      date
    end
  end

  def date_trunc(date, :year) do
    {:ok, date} = Date.from_iso8601("#{date.year}-01-01")
    date
  end
end
