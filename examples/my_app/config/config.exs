import Config

config :my_app, ecto_repos: [MyApp.Repo]

config :my_app, MyApp.Repo,
  database: "ecto_oban",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :my_app, Oban,
  repo: MyApp.Repo,
  queues: [default: 10, batch: 50, scheduled: 10, exports: 10]
