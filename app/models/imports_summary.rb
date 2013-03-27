class ImportsSummary
  include Mongoid::Document

  field :customers_import_locked, :type Boolean
  field :customers_import_last_ran_at, DateTime
  field :customers_import_last_processed_ts, Integer

  field :subscriptions_import_locked, :type Boolean
  field :subscriptions_import_last_ran_at, DateTime
  field :subscriptions_import_last_processed_ts, Integer

  embedded_in :users, :inverse_of => :imports_summary
end
