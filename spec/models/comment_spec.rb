require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'CRUD operations' do
    before(:each) do
      category = Category.create(name: "Category 1")
      category_id = category.id;
      article = Article.create(
        title: 'Sample Article', 
        body: 'This is a sample article.',
        category_id: category_id,
        status: 'public')
      article_id = article.id;
      @comment = Comment.create(
        commenter: 'John Doe',
        body: 'This is comment.',
        article_id: article_id,
        status: 'public'
      )
    end

    it 'creates a new comment' do
      expect(@comment).to be_valid
    end

    it "reads an existing comment" do
      expect(Comment.find_by_commenter(@comment.commenter)).to eq(@comment)
    end

    it "updates an existing comment" do
      @comment.update(body: "This is new comment.")
      expect(@comment.reload.body).to eq("This is new comment.")
    end

    it "deletes an existing comment" do
      expect {
        @comment.destroy
      }.to change(Comment, :count).by(-1)
    end
  end

  describe 'associations' do
    it 'belongs to a article' do
      association = described_class.reflect_on_association(:article)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
