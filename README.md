# Copilot

See this Docs:


- [PROJECT_VISION](docs/PROJECT_VISION.md)
- [API_ENDPOINTS](docs/API_ENDPOINTS.md)
- [API_TEST_SCENARIOS](docs/API_TEST_SCENARIOS.md)
- [DATA_MODELS](docs/DATA_MODELS.md)
- [CORE_SERVICE_WORKFLOWS](docs/CORE_SERVICE_WORKFLOWS.md)
- [AUTHENTICATION_AUTHORIZATION](docs/AUTHENTICATION_AUTHORIZATION.md)


> [!WARNING]
> Please keep [GEMINI.md](GEMINI.md) up to date!


 Here is a Markdown table created from the information you provided.
| Command | Description |
|---|---|
| mix deps.get | Install project dependencies. |
| mix test | Run the test suite. |
| mix format | Format the Elixir code. |
| mix phx.server | Start the Phoenix web server. |
| mix test --trace | Run the test suite with tracing. |
| mix compile | Compile the project. |
| copilot | Loads environment variables, run tests and then start the server. |
| copilot_apitest | Copies over the changes from external_file_copies/api_test.ex to <ApiTest-Project>/lib/api_test.ex and compiles and runs the test suite in the external directory. |
| checkin_apitest | Checks in the project in the external directory to git. Requires commit message parameter. |
| push_apitest | Pushes the project in the external directory to git. Returns to copilot root directory afterwards. |


#### TODO:
- [ ] add more information here.