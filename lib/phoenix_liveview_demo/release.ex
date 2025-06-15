defmodule PhoenixLiveviewDemo.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :phoenix_liveview_demo

  def migrate do
    load_app()

    for repo <- repos() do
      # 🩸 Ensure repo is started
      {:ok, _pid} = repo.start_link(pool_size: 2)
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _pid} = repo.start_link(pool_size: 2)
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    IO.puts("🔧 Loading and starting application #{@app}...")

    case Application.ensure_all_started(@app) do
      {:ok, _} ->
        :ok

      {:error, {:already_started, _}} ->
        :ok

      {:error, reason} ->
        IO.puts("❌ Failed to start app: #{inspect(reason)}")
        exit(:shutdown)
    end
  end
end
