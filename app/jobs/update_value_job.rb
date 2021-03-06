class UpdateValueJob < ApplicationJob
  queue_as :default

  def perform(row_value)
    db_manager = ::Natural::DatabaseManager.new
    db = db_manager.database(row_value.column.table.database.database_identifier)
    table = db.table(row_value.column.table.name)
    table.update_value(row_value.column.name, row_value.row.db_id, row_value.value)
  end
end
