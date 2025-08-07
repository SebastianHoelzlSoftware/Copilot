# Dev Request Service

## Copilot.Core.Data.User
  ```
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :provider_id, :string
    field :email, :string
    field :name, :string
    field :roles, {:array, :string}, default: []

    belongs_to :customer, Copilot.Core.Data.Customer


    timestamps()
  end
  ```

## Copilot.Core.Data.Customer
  ```
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "customers" do
    embeds_one :name, Name, on_replace: :delete
    embeds_one :address, Address, on_replace: :delete

    has_many :contacts, Contact, on_delete: :delete_all
    has_many :project_briefs, ProjectBrief, on_delete: :delete_all
    has_many :cost_estimates, CostEstimate, on_delete: :delete_all
    has_many :users, User, on_delete: :delete_all

    timestamps()
  end
  ```

## Copilot.Core.Data.Contact
  ```
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    embeds_one :name, Name, on_replace: :delete
    embeds_one :email, Email, on_replace: :delete
    embeds_one :address, Address, on_replace: :delete
    embeds_one :phone_number, PhoneNumber, on_replace: :delete
    belongs_to :customer, Customer
    timestamps()
  end
  ```

## Copilot.Core.Data.Name
  ```
  @primary_key false
  embedded_schema do
    field :company_name, :string
    field :first_name, :string
    field :last_name, :string
  end
  ```

## Copilot.Core.Data.Email
  ```
  @primary_key false
  embedded_schema do
    field :address, :string
  end
  ```

## Copilot.Core.Data.Address 
  ```
  @primary_key false
  embedded_schema do
    field :street, :string
    field :street_additional, :string
    field :city, :string
    field :postal_code, :string
    field :country, :string
  end
  ```

## Copilot.Core.Data.PhoneNumber
  ```
  @primary_key false
  embedded_schema do
    field :number, :string
  end
  ```

## Copilot.Core.Data.ProjectBrief
  ```
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_briefs" do
    field :title, :string
    field :summary, :string
    field :status, Ecto.Enum, values: [:new, :under_review, :accepted, :declined], default: :new
    field :developer_id, :binary_id

    belongs_to :customer, Customer
    has_one :ai_analysis, AIAnalysis

    timestamps()
  end
  ```

## Copilot.Core.Data.AIAnalysis
  ```
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ai_analyses" do
    embeds_many :suggested_blocks, BuildingBlock
    embeds_many :clarifying_questions, ClarifyingQuestion
    field :summary, :string
    field :identified_ambiguities, {:array, :string}, default: []

    belongs_to :project_brief, ProjectBrief
    belongs_to :cost_estimate, CostEstimate

    timestamps()
  end
  ```

## Copilot.Core.Data.BuildingBlock
  ```
  @primary_key false
  embedded_schema do
    field :name, :string
    field :description, :string
  end
  ```

## Copilot.Core.Data.ClarifyingQuestion
  ```
  @primary_key false
  embedded_schema do
    field :question, :string
    field :answer_type, :string, default: "text"
  end
  ```

## Copilot.Core.Data.CostEstimate
  ```
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cost_estimates" do
    field :amount, :decimal
    field :currency, :string
    field :details, :string

    # Assuming a cost estimate belongs to a customer
    belongs_to :customer, Customer

    has_one :ai_analysis, AIAnalysis

    timestamps()
  end
  ```
