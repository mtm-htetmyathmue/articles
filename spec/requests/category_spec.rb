require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:valid_user) { User.create(email: 'user@example.com', password: 'password', name: 'John') }
  
  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all categories to @categories' do
      category = Category.create(name: 'Category 1')
      get :index
      expect(assigns(:categories)).to eq([category])
    end

  end

  describe 'GET #show' do
    it 'returns a successful response' do
      category = Category.create(name: 'Example Category')
      get :show, params: { id: category.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:category)).to eq(category)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      sign_in valid_user
      get :new
      category = Category.create(name: 'Example Category')
      expect(response).to have_http_status(:success)
      expect(assigns(:category)).to be_a_new(Category)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    it 'creates a new category' do
      sign_in valid_user
      category_params = { name: 'New Category' }

      expect {
        post :create, params: { category: category_params }
      }.to change(Category, :count).by(1)

      expect(response).to redirect_to(category_path(assigns(:category)))
      expect(flash[:notice]).to eq('Category was successfully created.')
    end

    it 'renders :new if category creation fails' do
      sign_in valid_user
      invalid_category_params = { name: '' }
      post :create, params: { category: invalid_category_params }
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      sign_in valid_user
      category = Category.create(name: 'Example Category')
      get :edit, params: { id: category.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:category)).to eq(category)
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    it 'updates the category' do
      sign_in valid_user
      category = Category.create(name: 'Old Category')
      new_category_name = 'Updated Category'
      patch :update, params: { id: category.id, category: { name: new_category_name } }
      expect(response).to redirect_to(category_path(assigns(:category)))
      expect(flash[:notice]).to eq('Category was successfully updated.')
      expect(category.reload.name).to eq(new_category_name)
    end

    it 'renders :edit if category update fails' do
      sign_in valid_user
      category = Category.create(name: 'Old Category')
      invalid_category_params = { name: '' }
      patch :update, params: { id: category.id, category: invalid_category_params }
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the category' do
      sign_in valid_user
      category = Category.create(name: 'Category to be Destroyed')
      expect {
        delete :destroy, params: { id: category.id }
      }.to change(Category, :count).by(-1)

      expect(response).to redirect_to(categories_path)
      expect(flash[:notice]).to eq('Category was successfully destroyed.')
    end
  end
end
