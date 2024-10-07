require 'rails_helper'

RSpec.describe Task, type: :model do
  # Create users and projects for testing
  let!(:user) { User.create(name: "John Doe", email: "john@example.com", password: "password123", position: "Developer") }
  let!(:project) { Project.create(name: "Test Project") }
  let!(:task) { Task.create(task_title: "Test Task", description: "Test task description", assign_date: 1.day.ago, due_date: 1.day.from_now, status: "Todo", priority: "Urgent", user: user, project: project) }

  # Test validations
  context 'Validations' do
    it 'is valid with valid attributes' do
      expect(task).to be_valid
    end

    it 'is not valid without a task title' do
      task.task_title = nil
      expect(task).not_to be_valid
      expect(task.errors[:task_title]).to include("can't be blank")
    end

    it 'is not valid without a user' do
      task.user = nil
      expect(task).not_to be_valid
      expect(task.errors[:user]).to include("must exist")
    end

    it 'is not valid without a project' do
      task.project = nil
      expect(task).not_to be_valid
      expect(task.errors[:project]).to include("must exist")
    end

    it 'is not valid with an invalid status' do
      task.status = "InvalidStatus"
      expect(task).not_to be_valid
      expect(task.errors[:status]).to include("is not included in the list")
    end
  end

  # Test associations
  context 'Associations' do
    it 'belongs to a user' do
      expect(task.user).to eq(user)
    end

    it 'belongs to a project' do
      expect(task.project).to eq(project)
    end
  end

  # Test soft delete behavior (acts_as_paranoid)
  context 'Soft delete' do
    it 'soft deletes a task' do
      task.destroy
      expect(task.reload.deleted_at).not_to be_nil
    end

    it 'restores a task' do
      task.destroy
      task.restore
      expect(task.reload.deleted_at).to be_nil
    end
  end
end
