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
  The `User` model represents an user account for any physical user in the real world. Each user has it's own profile page to access it's or the company's data. The user can be a customer, a developer, or a business operator. There will be a special admin user in future. Users that register via the api/register route will be crated with the roles ["customer", "user"]. Users with the "developer" role will have more privileges on data than the regular "customer" user who can only retrieve data associated with himself or his company. The `email` field is used as an identifier in the physical world and thus must be unique, too. There can be many users for a customer. If so, the first user will be created with "allow_invite" role to be able to add more users for this customer.

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

  A customer represents the entity that the project is intended to be developed for. This can either be a single user who is then also the customer or a company with more than one user associated to it's data. Each customer will create one or more project briefs and has one or more Contacts. The `address` field is uses as a primary company address (or an individual customer's address) differing from the Contacts address field, as it won't be used for communicaion but as a business address that will be found in an invoice header for example later. Cost estimates also belong to the customer and not to an user account.

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

  A customer's contact data set. There can be more than one contact associated with a customer. Just like in an address book. The `name`, `email`, `address`, and `phone_number` fields are all embedded schemas.

## Copilot.Core.Data.Name
  ```
  @primary_key false
  embedded_schema do
    field :company_name, :string
    field :first_name, :string
    field :last_name, :string
  end
  ```

  An embedded schema for the Contact entity.

## Copilot.Core.Data.Email
  ```
  @primary_key false
  embedded_schema do
    field :address, :string
  end
  ```

  An embedded schema for the Contact entity.


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

  An embedded schema for the Contact entity.

## Copilot.Core.Data.PhoneNumber
  ```
  @primary_key false
  embedded_schema do
    field :number, :string
  end
  ```

  An embedded schema for the Contact entity.


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

  This entity holds information about the project that shall be developed by the developer. It will be produced by the customer after he has created a customer account. It's most important field is the summary field which will be used to decide whether to accept or decline a project and make a cost-estimate. For each project brief an ai_analysis will be either automatically created after the submission of the customer's project brief or it will (optionally) be created in interaction with the customer while he is creating the brief and as "AI suggestions" turned on. The project brief will be available for the developer for review and edit after it was submitted by the custumer. The review will be sent back and forth by the customer and the developer to come to an agreement. When this agreement is in a good state, a cost estimate can be provided to the customer by the business-operator, based on the review the developer has made.

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

  This holds data that the AI has attaced to the project brief. It will contain a summary (based on the customer's project brief's summary and general development considerations)

## Copilot.Core.Data.BuildingBlock
  ```
  @primary_key false
  embedded_schema do
    field :name, :string
    field :description, :string
  end
  ```

  To be able to create a better cost estimate and also help the customer getting a better overview of what his project might consist of (in the sense of common building blocks, like a web shop, etc.) there will be first the attempt (either by the customer himself or along with AI assistance) to identify those building blocks as decision base for the developer. Those building blocks are optional for the customer's project brief creation and can also be added later by AI assistant or the developer himself. They are valuable for a cost estimate but not necessary.


## Copilot.Core.Data.ClarifyingQuestion
  ```
  @primary_key false
  embedded_schema do
    field :question, :string
    field :answer_type, :string, default: "text"
  end
  ```

  Those are the inconsistencies the AI assistent might have identified after the project brief summary was typed in by the customer. Or after it was submitted but not yet reviewed by the developer. So those quesions can either be answered directly by the customer alongside AI assisted brief creation or later by the back and forth communication with the developer.

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

  Based on common building blocks, complexity and economic considerations the business operator will create (with the help of AI assistent or without) a cost estimate that he will send to the customer. The cost estimate will contain the ai_analysis and a details field where the human - approved details for the cost estimate belong. 
  #### TODO
  - [ ] Clarify if the ai_analysis should be readable by the customer

## Copilot.Core.Data.TimeEntry
  ```
  defmodule Copilot.Core.Data.TimeEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Copilot.Core.Data.ProjectBrief
  alias Copilot.Core.Data.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "time_entries" do
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime
    field :description, :string

    belongs_to :developer, User, type: :binary_id
    belongs_to :project, ProjectBrief, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(time_entry, attrs) do
    time_entry
    |> cast(attrs, [:start_time, :end_time, :description, :developer_id, :project_id])
    |> validate_required([:start_time, :end_time, :developer_id, :project_id])
    |> foreign_key_constraint(:developer_id)
    |> foreign_key_constraint(:project_id)
    |> validate_end_time_after_start_time()
  end

  defp validate_end_time_after_start_time(changeset) do
    start_time = get_field(changeset, :start_time)
    end_time = get_field(changeset, :end_time)

    if start_time && end_time && NaiveDateTime.compare(end_time, start_time) in [:lt, :eq] do
      add_error(changeset, :end_time, "must be after start time")
    else
      changeset
    end
  end
end
```