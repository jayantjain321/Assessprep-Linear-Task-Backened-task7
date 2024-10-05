require 'rails_helper'

RSpec.describe 'Projects', type: :request do
  # Create a user and a project creator for testing
  let(:user) { create(:user) }
  let(:project_creator) { create(:user) }
  
  # Create a project owned by the project creator
  let(:project) { create(:project, project_creator_id: project_creator.id) }

  # Valid attributes for a new project
  let(:valid_attributes) {
    {
      project: {
        name: 'New Project',
        description: 'A detailed description of the new project.',
        status: 'active',
        start_date: '2024-10-01',
        end_date: '2024-12-31'
      }
    }
  }

  # Invalid attributes (missing required name)
  let(:invalid_attributes) {
    {
      project: {
        name: '',  # Invalid because name is required
        description: 'Project description',
        status: 'active',
        start_date: '2024-10-01',
        end_date: '2024-12-31'
      }
    }
  }

  # Mock current_user method to return the project creator
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(project_creator)
  end

  # Test suite for creating a new project
  describe 'POST /api/v1/users/:id/projects' do
    context 'when the user exists' do
      it 'creates a new project' do
        # Attempt to create a new project with valid attributes
        post "/api/v1/users/#{user.id}/projects", params: valid_attributes, headers: authenticated_headers(user)

        # Expect a successful response with project creation confirmation
        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Project Created Successfully')
        expect(json['project']['name']).to eq('New Project')
      end
    end

    context 'when the user does not exist' do
      it 'returns a not found error' do
        # Attempt to create a project for a non-existent user
        post "/api/v1/users/-1/projects", params: { project: { name: 'Invalid' } }, headers: authenticated_headers(user)

        # Expect a not found response indicating the user does not exist
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('User not found')
      end
    end
  end

  # Test suite for retrieving projects with pagination
  describe 'GET /api/v1/projects' do
    context 'when there are projects' do
      before do
        # Create a list of projects for testing pagination
        create_list(:project, 15, project_creator_id: project_creator.id)
      end

      it 'returns a paginated list of projects' do
        # Request the first page of projects
        get "/api/v1/projects", params: { page: 1 }, headers: authenticated_headers(user)

        # Expect the response to be successful with the correct number of projects
        expect(response).to have_http_status(:ok)
        expect(json['projects'].size).to eq(10)  # Assuming pagination returns 10 projects per page
      end
    end
  end

  # Test suite for retrieving tasks related to a project
  describe 'GET /api/v1/projects/:id' do
    context 'Shows the tasks of a project' do
      it 'returns the tasks of a project' do
        # Request to get tasks for the specific project
        get "/api/v1/projects/#{project.id}", headers: authenticated_headers(user)

        # Expect a successful response with tasks returned as an array
        expect(response).to have_http_status(:ok)
        expect(json['tasks']).to be_a(Array)
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        # Request a project that does not exist
        get '/api/v1/projects/9999', headers: authenticated_headers(user)

        # Expect a not found response indicating the project does not exist
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Project not found')
      end
    end
  end

  # Test suite for deleting a project
  describe 'DELETE /api/v1/projects/:id' do
    context 'when the project exists and belongs to the user' do
      it 'deletes the project' do
        # Attempt to delete the existing project
        delete "/api/v1/projects/#{project.id}", headers: authenticated_headers(user)

        # Expect a successful response confirming deletion
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Project deleted successfully')
      end
    end

    context 'when the project does not belong to the user' do
      let(:other_user) { create(:user) }

      it 'returns a forbidden error' do
        # Mock current_user to simulate a different user
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
        
        # Attempt to delete the project as a different user
        delete "/api/v1/projects/#{project.id}", headers: authenticated_headers(other_user)

        # Expect a forbidden response indicating unauthorized access
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        # Attempt to delete a project that does not exist
        delete '/api/v1/projects/9999', headers: authenticated_headers(user)

        # Expect a not found response indicating the project does not exist
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Project not found')
      end
    end
  end

  # Test suite for updating a project
  describe 'PUT /api/v1/projects/:id' do
    context 'when the project exists and belongs to the user' do
      it 'updates the project' do
        valid_attributes = { project: { name: 'Updated Project' } }

        # Attempt to update the project with new attributes
        put "/api/v1/projects/#{project.id}", params: valid_attributes, headers: authenticated_headers(user)

        # Expect a successful response confirming the update
        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Project updated successfully')
        expect(json['project']['name']).to eq('Updated Project')
      end
    end

    context 'when the project does not belong to the user' do
      let(:other_user) { create(:user) }

      it 'returns a forbidden error' do
        # Mock current_user to simulate a different user
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)

        valid_attributes = { project: { name: 'Updated Project' } }

        # Attempt to update the project as a different user
        put "/api/v1/projects/#{project.id}", params: valid_attributes, headers: authenticated_headers(other_user)

        # Expect a forbidden response indicating unauthorized access
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        # Attempt to update a project that does not exist
        put '/api/v1/projects/9999', params: { project: { name: 'Some Name' } }, headers: authenticated_headers(user)

        # Expect a not found response indicating the project does not exist
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Project not found')
      end
    end
  end
end
