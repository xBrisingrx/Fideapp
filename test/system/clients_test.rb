require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  setup do
    @client = clients(:one)
  end

  test "visiting the index" do
    visit clients_url
    assert_selector "h1", text: "Clients"
  end

  test "creating a Client" do
    visit clients_url
    click_on "New Client"

    check "Active" if @client.active
    fill_in "Direction", with: @client.direction
    fill_in "Dni", with: @client.dni
    fill_in "Email", with: @client.email
    fill_in "Last name", with: @client.last_name
    fill_in "Marital status", with: @client.marital_status
    fill_in "Name", with: @client.name
    fill_in "Phone", with: @client.phone
    click_on "Create Client"

    assert_text "Client was successfully created"
    click_on "Back"
  end

  test "updating a Client" do
    visit clients_url
    click_on "Edit", match: :first

    check "Active" if @client.active
    fill_in "Direction", with: @client.direction
    fill_in "Dni", with: @client.dni
    fill_in "Email", with: @client.email
    fill_in "Last name", with: @client.last_name
    fill_in "Marital status", with: @client.marital_status
    fill_in "Name", with: @client.name
    fill_in "Phone", with: @client.phone
    click_on "Update Client"

    assert_text "Client was successfully updated"
    click_on "Back"
  end

  test "destroying a Client" do
    visit clients_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Client was successfully destroyed"
  end
end
