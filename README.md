```
      WOJTILA's                                         2025
      ░█████╗░░█████╗░██████╗░██╗██╗░░░░░░█████╗░████████╗
      ██╔══██╗██╔══██╗██╔══██╗██║██║░░░░░██╔══██╗╚══██╔══╝
      ██║░░╚═╝██║░░██║██████╔╝██║██║░░░░░██║░░██║░░░██║░░░
      ██║░░██╗██║░░██║██╔═══╝░██║██║░░░░░██║░░██║░░░██║░░░
      ╚█████╔╝╚█████╔╝██║░░░░░██║███████╗╚█████╔╝░░░██║░░░
      ░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░
```

Docs:

1. [PROJECT_VISION](docs/PROJECT_VISION.md)
2. [API_ENDPOINTS](docs/API_ENDPOINTS.md)
3. [API_TEST_SCENARIOS](docs/API_TEST_SCENARIOS.md)
4. [DATA_MODELS](docs/DATA_MODELS.md)
5. [CORE_SERVICE_WORKFLOWS](docs/CORE_SERVICE_WORKFLOWS.md)
6. [AUTHENTICATION_AUTHORIZATION](docs/AUTHENTICATION_AUTHORIZATION.md)

For the Time Manager or Time Tracker Service view [TIME_MANAGER.md](docs/TIME_MANAGER.md).


> [!WARNING]
> Please keep [GEMINI.md](GEMINI.md) up to date!


## Common Commands 

| Command | Description |
|---|---|
| `mix deps.get` | Install project dependencies. |
| `mix test` | Run the test suite. |
| `mix format` | Format the Elixir code. |
| `mix phx.server` | Start the Phoenix web server. |
| `mix test --trace` | Run the test suite with tracing. |
| `mix compile` | Compile the project. |
| `copilot` (shell alias)| Loads environment variables, run tests and then start the server. |
| `copilot_apitest` (shell alias)| Copies over the changes from external_file_copies/api_test.ex to <ApiTest-Project>/lib/api_test.ex and compiles and runs the test suite in the external directory. |
| `checkin_apitest` (shell alias)| Checks in the project in the external directory to git. Requires commit message parameter. |
| `push_apitest` (shell alias)| Pushes the project in the external directory to git. Returns to copilot root directory afterwards. |


### Shell Aliases (compare table above)

```
alias copilot="source ~/copilot/.env && cd ~/copilot && mix test && mix phx.server"
alias copilot_apitest='(cd ~/api_test && cp ~/copilot/external_file_copies/api_test.ex lib/api_test.ex && mix compile && mix run -e "ApiTest.run()")'
```
Note that the `copilot_apitest` command needs the apitest project present (Not included in this repo yet).


## Setup
1. Clone the Repo.
2. Add the above alias for the `copilot` command to your ~/.bashrc shell source file. Adjust the paths to the repo if needed. For Windows do it differently.
3. Set up a postgres database and adjust the database credentials in both the `test.exs` and `dev.exs` in the `config` folder in the project's root directory.
4. If you want to use the Logflase Logger Backend add the following to the project's .env file:

      ```
      export LOGFLARE_DEV_API_KEY="XXXXX...XXX"
      export LOGFLARE_DEV_SOURCE_ID="XXX...XXXX"
      ```
      You will get the credentials when creating an account on logflare.


## Run App
Start app with the `copilot` shell alias.


#### TODO:
- [ ] add more information here.
