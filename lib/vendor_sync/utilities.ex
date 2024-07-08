defmodule VendorSync.Utilities do
  @moduledoc false

  @doc """
  Crawls through a list of work items, processing them concurrently and recursively.

  This function takes an initial list of work items and a processing function,
  then executes the work in a concurrent, breadth-first manner. It manages the
  state of seen work items to avoid duplicates and allows for dynamic addition
  of new work items during processing.

  ## Parameters

    * `initial_work` - A list of initial work items to process.
    * `func` - A function that processes each work item. It should return
      a tuple `{result, additional_tasks}`, where `result` can be any value
      and `additional_tasks` is a list of new work items to be processed.
    * `opts` - A keyword list of options:
      * `:max_concurrency` - Maximum number of concurrent tasks (default: 1).
      * `:timeout` - Timeout for each task in milliseconds (default: 5000).

  ## Returns

    A stream of results from processing the work items.

  ## Example

      initial_work = [1, 2, 3]
      VendorSync.Utilities.crawl(initial_work, fn x ->
        {x * 2, [x + 1]}
      end, max_concurrency: 2)
      |> Enum.to_list()
      # Returns [2, 4, 6, 8, 10]
  """
  def crawl(initial_work, func, opts \\ []) when is_list(initial_work) do
    seen = MapSet.new()
    max_concurrency = Keyword.get(opts, :max_concurrency, 1)
    timeout = Keyword.get(opts, :timeout, 5000)

    Stream.resource(
      fn -> {initial_work, seen, []} end,
      fn
        {[], _, []} ->
          {:halt, {[], [], []}}

        {tasks, seen, running_tasks} ->
          {new_tasks, remaining_tasks} =
            Enum.split(tasks, max_concurrency - length(running_tasks))

          new_running_tasks =
            Enum.map(new_tasks, fn task -> Task.async(fn -> func.(task) end) end)

          seen = Enum.reduce(new_tasks, seen, &MapSet.put(&2, &1))

          all_running_tasks = running_tasks ++ new_running_tasks

          {results, still_running_tasks} =
            Task.yield_many(all_running_tasks, timeout)
            |> Enum.reduce({[], []}, fn
              {_task, {:ok, {result, additional_tasks}}}, {results, acc_running} ->
                new_tasks = additional_tasks |> Enum.reject(&MapSet.member?(seen, &1))
                {[{result, new_tasks} | results], acc_running}

              {task, nil}, {results, acc_running} ->
                {results, [task | acc_running]}
            end)

          new_tasks = Enum.flat_map(results, fn {_, additional_tasks} -> additional_tasks end)
          results = Enum.map(results, fn {result, _} -> result end)

          {results, {remaining_tasks ++ new_tasks, seen, still_running_tasks}}
      end,
      fn {_, _, running_tasks} ->
        Task.yield_many(running_tasks, :infinity)
        |> Enum.each(fn {task, _} -> Task.shutdown(task, :brutal_kill) end)
      end
    )
  end

  @doc """
  Casts all fields in a schema, including embedded and associated fields.
  """
  def cast_all(schema, params) do
    response_model = schema.__struct__
    fields = response_model.__schema__(:fields) |> MapSet.new()
    embedded_fields = response_model.__schema__(:embeds) |> MapSet.new()
    associated_fields = response_model.__schema__(:associations) |> MapSet.new()

    fields =
      fields
      |> MapSet.difference(embedded_fields)
      |> MapSet.difference(associated_fields)

    changeset = Ecto.Changeset.cast(schema, params, fields |> MapSet.to_list())

    changeset =
      for field <- embedded_fields, reduce: changeset do
        changeset ->
          changeset |> Ecto.Changeset.cast_embed(field, with: &cast_all/2)
      end

    changeset =
      for field <- associated_fields, reduce: changeset do
        changeset ->
          changeset |> Ecto.Changeset.cast_assoc(field, with: &cast_all/2)
      end

    changeset
  end

  def repo do
    Application.get_env(:vendor_sync, :repo)
  end

  def secret_key do
    Application.get_env(:vendor_sync, :stripe, []) |> Keyword.get(:secret_key)
  end
end
