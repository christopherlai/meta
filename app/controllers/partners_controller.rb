require 'core_ext/time_ext'

class PartnersController < ProductController
  before_action :find_product!

  def index
    @total_cents = 0

    entries = TransactionLogEntry.where(product_id: @product.id).with_cents.group(:user_id).sum(:cents)
    users = User.where(id: entries.keys).to_a

    @users = User.where(id: TransactionLogEntry.where(product_id: @product.id).with_cents.group(:user_id).count.keys)
    @user_cents = entries.map do |user_id, cents|
      @total_cents += cents
      [users.find{|u| u.id == user_id}, cents]
    end.sort_by{|u, c| -c }

    @auto_tips = Hash[AutoTipContract.active_at(@product, Time.now).pluck(:user_id, :amount).map{|user_id, amount| [User.find(user_id), amount] }]
  end

end
