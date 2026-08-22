class Item < ApplicationRecord
  belongs_to :list

  state_machine :current_state, initial: :pending do
    audit_trail class: ItemStateTransition

    event :complete do
      transition pending: :completed
    end
  end
end
