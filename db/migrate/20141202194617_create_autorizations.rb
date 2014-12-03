class CreateAutorizations < ActiveRecord::Migration
  def change
    create_table :autorizations do |t|
    	t.string :provider
		t.string :uid
		t.integer :user_id
		t.string :token
		t.string :secret
		t.string :username
      t.timestamps
    end
  end
end
