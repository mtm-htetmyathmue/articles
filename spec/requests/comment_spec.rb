require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe 'POST #create' do
    it 'creates a new comment with valid parameters' do
      category = Category.create(name: 'Category 1')
      article = Article.create(title: 'Test Article', body: 'Article Body', category_id: category.id, status: 'public')
      valid_comment_params = { commenter: 'John', body: 'Great Article!', status: 'public' }

      expect {
        post :create, params: { comment: valid_comment_params, article_id: article.id }
      }.to change(Comment, :count).by(1)

      expect(response).to redirect_to(article_path(article))
    end

    it 'does not create a new comment with invalid parameters' do
      category = Category.create(name: 'Category 1')
      article = Article.create(title: 'Test Article', body: 'Article Body', category_id: category.id, status: 'public')
      invalid_comment_params = { commenter: '', body: '', status: 'public' }
      expect {
        post :create, params: { comment: invalid_comment_params, article_id: article.id }
      }.not_to change(Comment, :count)

      expect(response).to redirect_to(article_path(article))
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the comment' do
      category = Category.create(name: 'Category 1')
      article = Article.create(title: 'Test Article', body: 'Article Body', category_id: category.id, status: 'public')
      article.save
      comment = article.comments.create(commenter: 'John', body: 'Great Article!', status: 'public')

      expect {
        delete :destroy, params: { article_id: article.id, id: comment.id }
      }.to change(Comment, :count).by(-1)

      expect(response).to redirect_to(article_path(article))
    end
  end
end
