class CreateTrialNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :trial_numbers do |t|
      t.string :mask_number
      t.string :forward_to_number
      t.string :sid
      t.timestamps
    end
  end
end
