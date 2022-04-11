class Web::BooksController < Web::WebApplicationController
  before_action :set_booth
  before_action :fetch_categories

  def index
    book_ids = @booth.books.pluck(:book_id)
    @books = Book.includes(:book_files).where(id: book_ids).order('created_at desc')
    # if params[:book].present?
    #   @books = @books.includes(:book_files).where("books.title ILIKE ? OR books.author_name ILIKE ?  OR books.body ILIKE ?", "%#{params[:book]}%", "%#{params[:book]}%", "%#{params[:book]}%" ).order('created_at desc')
    # elsif params[:category_id].present?
    #   book_ids = @categories.pluck(:book_id)
    #   @books = @books.where(id: book_ids)
    # end
    
    book_ids_from_operation = Operation.where(booth_id: @booth.id).pluck(:book_id)
    @trending_books = @books.where(id: book_ids_from_operation)
    @trending_books = @books if @trending_books.blank?
  end

  def search
    if params[:book].present?
      book_ids = @booth.books.pluck(:book_id)
      @books = Book.includes(:book_files).where(id: book_ids).order('created_at desc')
      @books = @books.includes(:book_files).where("books.title ILIKE ? OR books.author_name ILIKE ?  OR books.body ILIKE ?", "%#{params[:book]}%", "%#{params[:book]}%", "%#{params[:book]}%" ).order('created_at desc')
    elsif params[:category_id].present?
      book_ids = @booth.books.pluck(:book_id)
      @books = Book.includes(:book_files).where(id: book_ids).order('created_at desc')
      book_ids = @categories.pluck(:book_id)
      @books = @books.where(id: book_ids)
    end
  end

  def show
    @book = Book.where(id: params[:id]).first
    operation = Operation.create(booth_id: @booth.id, book_id: @book.id)
    
    path = media_files_web_operation_url(id: operation.number)
    @qr_code = RQRCode::QRCode.new(path)
  end

  def media_files
    @book = Book.where(id: params[:id]).includes(:book_files).first
    @book.update(last_listening_at: Time.now)
  end

  def update_listen_count
    render json: {message: "successfully save count"}
  end

  private

  def set_booth
    @booth = Booth.find_by(number: params[:booth_id])
    redirect_to web_booth_path(id: @booth.number), notice: "Invali Booth" if @booth.blank?
  end

  def fetch_categories
    @categories = @booth.categories
    if params[:category_id].present?
      @categories = @categories.includes(:books).where(id: params[:category_id])
    end
  end
end
