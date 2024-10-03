# spec/models/project_spec.rb
require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:project) { build(:project) }  # FactoryBot build method to create an instance

  # Validation tests
  describe "Validations" do
    it "is valid with valid attributes" do
      expect(project).to be_valid
    end

    it "is not valid without a name" do
      project.name = nil
      expect(project).to_not be_valid
    end

    it "is not valid with a duplicate name" do
      create(:project, name: "Duplicate Project Name")  # Create a project with this name
      project_with_duplicate_name = build(:project, name: "Duplicate Project Name")
      expect(project_with_duplicate_name).to_not be_valid
    end

    it "is not valid without a description" do
      project.description = nil
      expect(project).to_not be_valid
    end

    it "is not valid with a description shorter than 10 characters" do
      project.description = "Short"
      expect(project).to_not be_valid
    end

    it "is not valid without a status" do
      project.status = nil
      expect(project).to_not be_valid
    end

    it "is not valid with an invalid status" do
      project.status = "inactive"
      expect(project).to_not be_valid
    end

    it "is not valid without a start date" do
      project.start_date = nil
      expect(project).to_not be_valid
    end

    it "is not valid without an end date" do
      project.end_date = nil
      expect(project).to_not be_valid
    end

    it "is not valid if end date is before start date" do
      project.start_date = Date.today
      project.end_date = Date.yesterday
      expect(project).to_not be_valid
    end
  end

  # Association tests
  describe "Associations" do
    it { should have_and_belong_to_many(:users) }
    it { should have_many(:tasks).dependent(:destroy) }
  end

  # Acts as paranoid (soft delete) tests
  describe "Soft delete" do
    let!(:project_to_delete) { create(:project) }

    it 'soft deletes a project' do
      project_to_delete.destroy
      expect(project_to_delete.reload.deleted_at).not_to be_nil
    end

    it 'restores a project' do
      project_to_delete.destroy
      project_to_delete.restore
      expect(project_to_delete.reload.deleted_at).to be_nil
    end
  end
end
