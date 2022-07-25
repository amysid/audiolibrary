class Web::BooksController < Web::WebApplicationController
  before_action :set_booth, except: [:all_books, :play_book_for_blind]
  before_action :fetch_categories, except: [:all_books, :play_book_for_blind]

  def index
    book_ids = @booth.books.pluck(:book_id)
    @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')

    book_ids_from_operation = Operation.where(booth_id: @booth.id).pluck(:book_id)
    @trending_books = @books.where(id: book_ids_from_operation)
    @trending_books = @books if @trending_books.blank?
  end

  def all_books
    @books = Book.includes(:book_files).where(status: "Published").order('created_at desc')
  end

  def play_book_for_blind
    book = Book.find_by(id: params[:id])
    booth = Booth.where(name: "Blind").first_or_create
    operation = Operation.create(book_id: book.id, booth_id: booth.id)
    redirect_to media_files_web_operation_path(id: operation.number)
  end

  def search 
    if params[:book].present?
      book_ids = @booth.books.pluck(:book_id)
      @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
      @books = @books.includes(:book_files).where("books.title ILIKE ? OR books.author_name ILIKE ?  OR books.body ILIKE ?", "%#{params[:book]}%", "%#{params[:book]}%", "%#{params[:book]}%" ).order('created_at desc')
    end
    if params[:type] == "all"
     @books = @books
    elsif params[:type] == "short"
      @books = @books.where(audio_type: "Short") if @books.present?
    elsif params[:type] == "long"
      @books = @books.where(audio_type: "Long") if @books.present?
    end
  end

  def category_search
    if params[:category_id].present?
      book_ids = @booth.books.pluck(:book_id)
      @books = Book.includes(:book_files).where(id: book_ids, status: "Published")
      book_ids = @categories.pluck(:book_id)
      @books = @books.where(id: book_ids)
      @total_books = @books.count || 0
      total_time = @books.pluck(:book_duration).sum
      @total_time = Time.at(total_time).utc.strftime("%Hh %M minute")
      @total_author_count = @books.pluck(:author_name).uniq.count || 0
      
      if params[:type] == "all"
        @books = @books
      elsif params[:type] == "short"
        @books = @books.where(audio_type: "Short")
      elsif params[:type] == "long"
        @books = @books.where(audio_type: "Long")
      end
    end
  end

  def show
    @book = Book.where(id: params[:id]).first
    operation = Operation.create(booth_id: @booth.id, book_id: @book.id)
    
    path = media_files_web_operation_url(id: operation.number)
    @qr_code = RQRCode::QRCode.new(path)
    @qr_png = @qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 10,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 140
    )
  end

  def accessibility_mode
    book_ids = @booth.books.pluck(:book_id)
    @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
  end

  def children_mode
    @children_category = Category.where(name: "Children’s books").first
    cat_book_ids = @children_category.books.pluck(:id)
    book_ids = @booth.books.pluck(:book_id) & cat_book_ids
    
    @books = Book.includes(:book_files).where(id: book_ids, status: "Published").order('created_at desc')
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
