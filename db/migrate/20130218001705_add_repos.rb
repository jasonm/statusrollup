class AddRepos < ActiveRecord::Migration
  def up
    create_table :repos do |t|
      t.string :user_name
      t.string :repo_name
      t.integer :user_id
      t.integer :github_repo_hook_id
      t.timestamps
    end

    add_index :repos, [:user_name, :repo_name]
    add_index :repos, :user_id
  end

  def down
    remove_index :repos, :column => :user_id
    remove_index :repos, :column => [:user_name, :repo_name]

    drop_table :repos
  end
end
