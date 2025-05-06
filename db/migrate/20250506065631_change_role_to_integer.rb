class ChangeRoleToInteger < ActiveRecord::Migration[7.1]
  def up
    # First, convert existing string values to integers
    execute <<-SQL
      UPDATE users 
      SET role = CASE 
        WHEN role = 'basic_user' THEN 0
        WHEN role = 'shelter_staff' THEN 1
        WHEN role = 'admin' THEN 2
        ELSE 0
      END
    SQL

    # Then change the column type using USING clause
    execute <<-SQL
      ALTER TABLE users 
      ALTER COLUMN role TYPE integer 
      USING CASE 
        WHEN role = '0' THEN 0
        WHEN role = '1' THEN 1
        WHEN role = '2' THEN 2
        ELSE 0
      END,
      ALTER COLUMN role SET DEFAULT 0,
      ALTER COLUMN role SET NOT NULL
    SQL
  end

  def down
    # Convert integers back to strings
    execute <<-SQL
      UPDATE users 
      SET role = CASE 
        WHEN role = 0 THEN 'basic_user'
        WHEN role = 1 THEN 'shelter_staff'
        WHEN role = 2 THEN 'admin'
        ELSE 'basic_user'
      END
    SQL

    change_column :users, :role, :string
  end
end
