require 'rails_helper'

RSpec.describe Article, type: :model do

  describe 'CRUD operations' do
    before(:each) do
      category = Category.create(name: "Category 1")
      category_id = category.id;
      @article = Article.create(
        title: 'Sample Article', 
        body: 'This is a sample article.',
        category_id: category_id,
        status: 'public')
      @article_id = @article.id 
    end

    it 'creates a new article' do
      expect(@article).to be_valid
    end

    it "reads an existing article" do
      expect(Article.find_by_title(@article.title)).to eq(@article)
    end

    it "updates an existing article" do
      @article.update(body: "This is new article.")
      expect(@article.reload.body).to eq("This is new article.")
    end

    it "deletes an existing article" do
      expect {
        @article.destroy
      }.to change(Article, :count).by(-1)
    end

    it 'deletes associated comments when article is destroyed' do
      comment1 = Comment.create(
        commenter: 'John Doe',
        body: 'This is comment.',
        article_id: @article_id,
        status: 'public'
      )
      comment2 = Comment.create(
        commenter: 'John',
        body: 'This is comment.',
        article_id: @article_id,
        status: 'public'
      )

      expect(@article.comments).to include(comment1, comment2)
      @article.destroy
      expect(Article.exists?(@article.id)).to be_falsey
      expect(Comment.exists?(comment1.id)).to be_falsey
      expect(Comment.exists?(comment2.id)).to be_falsey
    end

    it 'destroys attached image when article is destroyed' do
      image = fixture_file_upload('html.jpg', 'image/jpg')
      @article.image.attach(image)
      filename = @article.image.filename.to_s
      @article.destroy
      expect(Article.exists?(@article.id)).to be_falsey
      expect(ActiveStorage::Blob.service.exist?(filename)).to be_falsey
    end
  end

  describe 'associations' do
    it 'belongs to a category' do
      association = described_class.reflect_on_association(:category)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'has many comments with dependent destroy' do
      association = described_class.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has one attached image' do
      association = described_class.reflect_on_association(:image_attachment)
      expect(association.macro).to eq(:has_one)
    end
  end

  describe 'validations' do
    it 'validates presence of title' do
      article = described_class.new(title: nil, body: 'Lorem ipsum', category_id: nil, status: nil)
      expect(article).not_to be_valid
      expect(article.errors[:title]).to include("can't be blank")
    end

    it 'validates presence of body' do
      article = described_class.new(title: 'Lorem ipsum')
      expect(article).not_to be_valid
      expect(article.errors[:body]).to include("can't be blank")
    end

    it 'validates minimum length of body' do
      article = described_class.new(title: 'Title', body: 'Short')
      expect(article).not_to be_valid
      expect(article.errors[:body]).to include("is too short (minimum is 10 characters)")
    end
  end
end


