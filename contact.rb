lass Contact < ApplicationRecord
  has_many :call_logs, dependent: :destroy
  
  validates :phone_number, presence: true
  
  # For bulk import from text
  def self.import_from_text(text)
    numbers = text.split(/[\n,]/).map(&:strip).reject(&:blank?)
    count = 0
    numbers.each do |number|
      unless exists?(phone_number: number)
        create(phone_number: number, status: 'pending')
        count += 1
      end
    end
    count
  end
  
  # For CSV import
  def self.import_from_csv(file)
    require 'csv'
    count = 0
    CSV.foreach(file.path, headers: true) do |row|
      unless exists?(phone_number: row['phone_number'])
        create(
          phone_number: row['phone_number'],
          name: row['name'],
          status: 'pending'
        )
        count += 1
      end
    end
    count
  end
end
