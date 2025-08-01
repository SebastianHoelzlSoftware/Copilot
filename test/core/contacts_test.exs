defmodule CopilotApi.Core.ContactsTest do
  use CopilotApi.DataCase

  alias CopilotApi.Core.Contacts
  alias CopilotApi.Core.Data.Contact

  import CopilotApi.Core.Fixtures

  @invalid_attrs %{name: nil}

  describe "list_contacts/0" do
    test "returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts() == [contact]
    end
  end

  describe "get_contact!/1" do
    test "returns the contact with given id" do
      contact = contact_fixture()
      fetched_contact = Contacts.get_contact!(contact.id)

      assert fetched_contact.id == contact.id
      assert fetched_contact.customer
    end

    test "raises if the Contact does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(Ecto.UUID.generate()) end
    end
  end

  describe "create_contact/1" do
    test "with valid data creates a contact" do
      customer = customer_fixture()

      valid_attrs = %{
        customer_id: customer.id,
        name: %{first_name: "Jane", last_name: "Doe"},
        email: %{address: "jane.doe@example.com"},
        phone_number: %{number: "+15557654321"}
      }

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.customer_id == customer.id
      assert contact.name.first_name == "Jane"
      assert contact.email.address == "jane.doe@example.com"
      assert contact.phone_number.number == "+15557654321"
    end

    test "with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end
  end

  describe "update_contact/2" do
    test "with valid data updates the contact" do
      contact = contact_fixture()
      update_attrs = %{name: %{first_name: "Janet", last_name: contact.name.last_name}}

      assert {:ok, %Contact{} = updated_contact} =
               Contacts.update_contact(contact, update_attrs)

      assert updated_contact.name.first_name == "Janet"
      assert updated_contact.name.last_name == contact.name.last_name
    end

    test "with invalid data returns an error changeset" do
      contact = contact_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Contacts.update_contact(contact, @invalid_attrs)

      assert Contacts.get_contact!(contact.id).name.first_name == contact.name.first_name
    end
  end

  describe "delete_contact/1" do
    test "deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end
  end
end
