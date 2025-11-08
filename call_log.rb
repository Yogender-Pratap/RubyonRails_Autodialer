class CallLog < ApplicationRecord
  belongs_to :contact
  
  scope :successful, -> { where(status: 'completed') }
  scope :failed, -> { where(status: ['failed', 'busy', 'no-answer']) }
end
