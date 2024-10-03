# spec/models/task_spec.rb

require 'rails_helper'

RSpec.describe Task, type: :model do
  # Test soft delete behavior (acts_as_paranoid)
  context 'Soft delete' do
    let!(:user) { User.create(name: "John Doe", email: "john@example.com", password: "password123", position: "Developer") }
    let!(:project) { Project.create(name: "Test Project") }
    let!(:task) { Task.create(task_title: "Test Task", description: "Test task description", assign_date: 1.day.ago, due_date: 1.day.from_now, status: "Todo", priority: "Urgent", user: user, project: project) }

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
