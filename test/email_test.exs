defmodule CopilotApi.Core.Data.EmailTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.Email

  describe "new/1" do
    test "creates an email with a valid string" do
      assert {:ok, %Email{address: "test@example.com"}} = Email.new("test@example.com")
    end

    test "returns an error for an invalid email format" do
      assert {:error, :invalid_email_format} = Email.new("test@example")
      assert {:error, :invalid_email_format} = Email.new("test.example.com")
      assert {:error, :invalid_email_format} = Email.new("test@.com")
    end

    test "returns an error for a non-binary input" do
      assert {:error, :invalid_email_type} = Email.new(nil)
      assert {:error, :invalid_email_type} = Email.new(123)
      assert {:error, :invalid_email_type} = Email.new(%{})
    end
  end

  describe "to_string/1" do
    test "returns the email address as a string" do
      {:ok, email_struct} = Email.new("test@example.com")
      assert Email.to_string(email_struct) == "test@example.com"
    end
  end
end
