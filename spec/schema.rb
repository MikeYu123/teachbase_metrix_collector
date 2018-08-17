ActiveRecord::Schema.define do
  self.verbose = false

  create_table :parent_stats, :force => true do |t|
    t.integer :score
    t.integer :time_spent
    t.integer :lock_version

    t.timestamps
  end

  create_table :child_stats, :force => true do |t|
    t.integer :score
    t.integer :time_spent
    t.integer :lock_version
    t.references :parent_stat

    t.timestamps
  end

  create_table :insuitable_parent_stats, :force => true do |t|
    t.integer :some_other_stat

    t.timestamps
  end

  create_table :insuitable_child_stats, :force => true do |t|
    t.integer :some_other_stat
    t.integer :score
    t.references :insuitable_parent_stat

    t.timestamps
  end
end
