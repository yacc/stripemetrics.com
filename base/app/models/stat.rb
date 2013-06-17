class Stat
  include Mongoid::Document

  field :stripe_customers,     type: Integer
  field :stripe_charges,       type: Integer
  field :stripe_subscriptions, type: Integer
  field :stripe_cdes,          type: Integer
  field :stripe_sdes,          type: Integer

  embedded_in :user

  def import_progress(type)
    case type
    when 'ChargeImport'
      total_imports = user.charge_imports.first.count * user.charge_imports.count
      percent = total_imports.to_f / stripe_charges * 100.0
    when 'CustomerImport'
      total_imports = user.customer_imports.first.count * user.customer_imports.count
      percent =  total_imports.to_f / stripe_customers * 100.0
    when 'SdeImport'
      total_imports = user.sde_imports.first.count * user.sde_imports.count
      percent = total_imports.to_f / stripe_cdes * 100.0
    when 'CdeImport'
      total_imports = user.cde_imports.first.count * user.cde_imports.count
      percent =  total_imports.to_f / stripe_sdes  * 100.0
    end
    percent.ceil
  end

end
