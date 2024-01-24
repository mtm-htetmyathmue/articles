require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  include Devise::Test::ControllerHelpers
  describe 'GET #index' do
    let(:category) { Category.create(name: 'Category1') }
    let!(:articles) do
      10.times { |i| Article.create(title: "Article #{i + 1}", body: "This is body #{i + 1}", category_id: category.id, status: 'public') }
    end

    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'returns a successful response and loads the first page of articles' do
      get :index, params: { page: 1, per_page: 5}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expected_articles = Article.order("id DESC").page(1).per(5)
      assigned_articles = assigns(:articles)
      expected_articles.each_with_index do |article, index|
        expect(assigned_articles[index].title).to eq(article.title)
      end
    end

    it 'returns the specified page of articles' do
      get :index, params: { page: 2, per_page: 5}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      assigned_article = assigns(:articles)
      expect(assigned_article[0].title).to eq("Article 5")
      expect(assigned_article[1].title).to eq("Article 4")
    end
  end
  
  describe 'GET #show' do
    let(:category) {Category.create(name:"Category1")}
    let(:article) { Article.create(title:"article1",body:"this is an article",status:"public",category:category) }
    
    it 'returns a successful response' do
      get :show, params: { id: article.id }
      expect(response).to be_successful
    end

    it 'assigns the requested articles' do
      get :show, params: { id: article.id }
      expect(assigns(:article)).to eq(article)
    end

    it 'renders the show template' do
      get :show, params: { id: article.id }
      expect(response).to render_template('show')
    end
  end

  describe 'GET #new' do
    before(:each) do
      user = User.create(name: 'Jane Doe', email: 'jane@example.com', password: 'password')
      sign_in user
    end 
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new article to @article' do
      get :new
      expect(assigns(:article)).to be_a_new(Article)
    end
  end

  describe 'GET #edit' do
    before(:each) do
      category = Category.create(name:"Category1")
      @article = Article.create(title:"article1",body:"this is an article",status:"public",category:category)
      user = User.create(name: 'Jane Doe', email: 'jane@example.com', password: 'password')
      sign_in user
    end  

    it 'returns a successful response' do
      get :edit, params: { id: @article.id }
      expect(response).to be_successful
    end

    it 'assigns the requested article to @article' do
      get :edit, params: { id: @article.id }
      expect(assigns(:article)).to eq(@article)
    end
  end

  describe 'POST #create' do
    before(:each) do
      user = User.create(name: 'Jane Doe', email: 'jane@example.com', password: 'password')
      sign_in user
    end 

    context 'with valid parameters' do
      it 'creates a new article' do
        category = Category.create(name:"Category1")
        article_params = {title:"Hello",body:"this is sample article",status:"public",category_id:category.id}
        expect {
          post :create, params: { article: article_params }
        }.to change(Article, :count).by(1)
      end

      it 'redirects to the created article' do
        category = Category.create(name:"Category1")
        article_params = {title:"Hello",body:"this is sample article",status:"public",category_id:category.id}
        post :create, params: { article: article_params }
        expect(response).to redirect_to(article_path(Article.last))
      end
    end
    context 'with invalid parameters' do
      it 'does not create a new article' do
      invalid_params = {title: 'article'}
        expect {
          post :create, params: { article: invalid_params }
        }.not_to change(Article, :count)
      end
    
      it 'renders the new template' do
        invalid_params = {title: 'article'}
        post :create, params: { article: invalid_params }
        expect(response).to render_template(:new)
      end
    end 
  end
  
  describe 'PATCH #update' do
    before(:each) do
      user = User.create(name: 'Jane Doe', email: 'jane@example.com', password: 'password')
      sign_in user
    end

    let(:category) {Category.create(name:"Category1")}
    let(:article) { Article.create(title:"article1",body:"this is an article",status:"public",category:category) }
    
    context 'with valid parameters' do
      it "update the article" do
        new_title = "new title"
        patch :update, params: { id: article.id, article: { title: new_title } }
        article.reload
        expect(article.title).to eq(new_title)
      end

      it "update the article body" do
        new_body = "this is a new article"
        patch :update, params: { id: article.id, article: { body: new_body } }
        article.reload
        expect(article.body).to eq(new_body)
      end

      it "redirects to the updated article" do
        new_title = "new title"
        patch :update, params: { id: article.id, article: { title: new_title } }
        expect(response).to redirect_to(article)
      end

    end

    context "with invalid params" do
      it "does not update the article" do
        patch :update, params: { id: article.id, article: { title: "" } }
        article.reload
        expect(article.title).to_not eq("")
      end

      it 're-renders the edit template with status :unprocessable_entity' do
        patch :update, params: { id: article.id, article: { title: '' } }
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      category = Category.create(name:"Category1")
      @article = Article.create(title:"article1",body:"this is an article",status:"public",category:category)
      user = User.create(name: 'Jane Doe', email: 'jane@example.com', password: 'password')
      sign_in user
    end

    it 'destroys the requested article' do
      expect {
        delete :destroy, params: { id: @article.id }
      }.to change(Article, :count).by(-1)
    end

    it 'redirects to the articles list' do
      delete :destroy, params: { id: @article.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #search' do
    it 'redirects to root_path if search parameter is blank' do
      get :search, params: { search: '' }

      expect(response).to redirect_to(root_path)
      expect(assigns(:parameter)).to be_nil
      expect(assigns(:results)).to be_nil
    end

    it 'assigns results if search parameter is present' do
      category = Category.create(name: 'Category 1')
      article1 = Article.create(title: 'Ruby on Rails', body: 'Introduction to Rails', category_id: category.id, status: 'public')
      article2 = Article.create(title: 'JavaScript Basics', body: 'Getting started with JavaScript', category_id: category.id, status: 'public')

      get :search, params: { search: 'rails' }

      expect(response).to have_http_status(:success)
      expect(assigns(:parameter)).to eq('rails')
      expect(assigns(:results)).to eq([article1])
      expect(response).to render_template(:search)
    end
  end

end
