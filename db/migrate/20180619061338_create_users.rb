class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :password
      t.string :user_name
      t.string :mail_address

      t.timestamps
    end
  end
end
