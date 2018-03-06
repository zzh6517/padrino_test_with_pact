class CreateUsers < ActiveRecord::Migration[5.1]
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :age
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :users
  end
end
