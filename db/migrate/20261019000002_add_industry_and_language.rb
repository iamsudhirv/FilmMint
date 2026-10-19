class AddIndustryAndLanguage < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :industry, :string, null: false, default: "hollywood"
    add_column :films, :industry, :string, null: false, default: "hollywood"
    add_column :films, :language, :string
    add_index :people, :industry
    add_index :films, :industry
  end
end
