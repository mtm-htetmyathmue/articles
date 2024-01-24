require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "CRUD operations" do
    it "creates a new category" do
      category = Category.create(name: "New Category")
      expect(category).to be_valid
    end

    it "reads an existing category" do
      category = Category.create(name: "Existing Category")
      expect(Category.find_by_name(category.name)).to eq(category)
    end

    it "updates an existing category" do
      category = Category.create(name: "Old Category")
      category.update(name: "Updated Category")
      expect(category.reload.name).to eq("Updated Category")
    end

    it "deletes an existing category" do
      category = Category.create(name: "Category to Delete")
      expect {
        category.destroy
      }.to change(Category, :count).by(-1)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      category = Category.new(name: nil)
      category.valid?
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "is invalid with a non-unique name" do
      existing_category = Category.create(name: "Existing Category")
      new_category = Category.new(name: "Existing Category")
      new_category.valid?
      expect(new_category.errors[:name]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many articles" do
      association = described_class.reflect_on_association(:articles)
      expect(association.macro).to eq(:has_many)
    end
  end
end
