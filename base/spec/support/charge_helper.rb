module ChargeHelper

	def generate_charges_for_user
	  2.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-06-01"))}
    4.times {Charge.make!(user_id:user.id,created:Time.parse("2013-06-01"))}

    2.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-07-01"))}

    1.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-09-01"))}
	end

  def generate_charges_for_user_with_countries
    2.times {Charge.make!(paid:false,card:{country:'US'},user_id:user.id,created:Time.parse("2013-06-01"))}
    2.times {Charge.make!(paid:false,card:{country:'FR'},user_id:user.id,created:Time.parse("2013-06-01"))}
    4.times {Charge.make!(user_id:user.id,created:Time.parse("2013-06-01"))}

    2.times {Charge.make!(paid:false,card:{country:'US'},user_id:user.id,created:Time.parse("2013-07-01"))}
    2.times {Charge.make!(paid:false,card:{country:'BR'},user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(paid:false,card:{country:'FR'},user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-07-01"))}

    1.times {Charge.make!(paid:false,card:{country:'US'},user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-09-01"))}
  end

  def generate_charges_for_user_with_cc_types
    2.times {Charge.make!(paid:false,card:{card_type:'Visa'},user_id:user.id,created:Time.parse("2013-06-01"))}
    2.times {Charge.make!(paid:false,card:{card_type:'MasterCard'},user_id:user.id,created:Time.parse("2013-06-01"))}
    4.times {Charge.make!(user_id:user.id,created:Time.parse("2013-06-01"))}

    2.times {Charge.make!(paid:false,card:{card_type:'Visa'},user_id:user.id,created:Time.parse("2013-07-01"))}
    2.times {Charge.make!(paid:false,card:{card_type:'MasterCard'},user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(paid:false,card:{card_type:'Amex'},user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-07-01"))}

    1.times {Charge.make!(paid:false,card:{card_type:'Amex'},user_id:user.id,created:Time.parse("2013-08-01"))}
    1.times {Charge.make!(paid:false,card:{card_type:'Visa'},user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-09-01"))}
  end


  def generate_successfull_charges_for_user_with_cc_types
    2.times {Charge.make!(paid:true,card:{card_type:'Visa'},user_id:user.id,created:Time.parse("2013-06-01"))}
    2.times {Charge.make!(paid:true,card:{card_type:'MasterCard'},user_id:user.id,created:Time.parse("2013-06-01"))}
    4.times {Charge.make!(user_id:user.id,created:Time.parse("2013-06-01"))}

    2.times {Charge.make!(paid:true,card:{card_type:'Visa'},user_id:user.id,created:Time.parse("2013-07-01"))}
    2.times {Charge.make!(paid:true,card:{card_type:'MasterCard'},user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(paid:true,card:{card_type:'Amex'},user_id:user.id,created:Time.parse("2013-07-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-07-01"))}

    1.times {Charge.make!(paid:true,card:{card_type:'Amex'},user_id:user.id,created:Time.parse("2013-08-01"))}
    1.times {Charge.make!(paid:true,card:{card_type:'Visa'},user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-08-01"))}
    3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-09-01"))}
  end

end
