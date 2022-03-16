class Web::BooksController < ApplicationController
  before_action :set_booth
  before_action :fetch_categories

  def index
    if params[:book].present?
      @books = Book.where(category_id: @categories.pluck(:id)).where("books.title LIKE ?", "%#{params[:book]}%")
    else
      @books = Book.where(category_id: @categories.pluck(:id))
    end
  end

  def show
    @book = Book.where(id: params[:id]).first
    path = media_files_web_booth_book_url(booth_id: @booth.number, id: @book)
    @qr_code = RQRCode::QRCode.new(path)
  end

  def media_files
    @book = Book.where(id: params[:id]).includes(:book_files).first
  end

  private

  def set_booth
    @booth = Booth.find_by(number: params[:booth_id])
    redirect_to web_booth_path(id: @booth.number), notice: "Invali Booth" if @booth.blank?
  end

  def fetch_categories
    @categories = @booth.categories
  end
end
