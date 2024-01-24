require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'CRUD operations' do
    it 'creates a new user' do
      user = User.create(name: 'John Doe', email: 'john@example.com', password: 'password')
      expect(user).to be_valid
    end

    it 'reads a user' do
      user = User.create(name: 'Jane Doe', email: 'jane@example.com', password: 'password')
      retrieved_user = User.find(user.id)
      expect(retrieved_user.name).to eq('Jane Doe')
      expect(retrieved_user.email).to eq('jane@example.com')
    end

    it 'updates a user' do
      user = User.create(name: 'Old Name', email: 'old@example.com', password: 'password')
      user.update(name: 'New Name', email: 'new@example.com', password: 'new password')
      expect(user.reload.name).to eq('New Name')
      expect(user.reload.email).to eq('new@example.com')
      expect(user.reload.password).to eq('new password')
    end

    it 'deletes a user' do
      user = User.create(name: 'To be deleted', email: 'delete@example.com', password: 'password')
      user.destroy
      expect(User.find_by(email: 'delete@example.com')).to be_nil
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      user = User.new(name: nil)
      user.valid?
      expect(user.errors[:name]).to include("can't be blank")
    end
  end
end
