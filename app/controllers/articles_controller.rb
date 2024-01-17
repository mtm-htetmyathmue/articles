class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search]
  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy
  
  def index
    @articles = Article.paginate(page: params[:page], per_page: 5)
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  def search
    if params[:search].blank?
      redirect_to root_path and return
    else
      @parameter = params[:search].downcase
      @results = Article.where("title LIKE :search", search: "%#{@parameter}%")
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :image, :status, :category_id)
    end

 

end
