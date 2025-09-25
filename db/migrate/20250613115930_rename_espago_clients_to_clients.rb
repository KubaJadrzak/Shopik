# frozen_string_literal: true

class RenameEspagoClientsToClients < ActiveRecord::Migration[8.0]
  def change
    rename_table :espago_clients, :clients
  end
end
