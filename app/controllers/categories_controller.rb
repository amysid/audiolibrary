class CategoriesController < ApplicationController
  before_action :logged_in?
  def index
    @category = Category.new
    @categories = Category.all.includes(:booths)
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      message = t('category_created_successfully')
      redirect_to categories_path, notice: message
    else
      redirect_to booths_path, alert: @booth.errors.full_messages
    end
  end

  def update
    @category = Category.find_by(params[:id])
    redirect_to booths_path, alert: t("no_record_present")

    if @category.update(category_params) 
      message = t('category_updated_successfully')
      redirect_to categories_path, notice: message 
    else
      redirect_to booths_path, alert: @booth.errors.full_messages
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
