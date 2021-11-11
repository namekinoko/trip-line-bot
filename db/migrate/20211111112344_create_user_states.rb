class CreateUserStates < ActiveRecord::Migration[6.1]
  def change
    create_table :user_states do |t|
      t.string :userid
      t.integer :status
      t.timestamps
    end
  end
end
