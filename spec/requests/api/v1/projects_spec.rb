require 'rails_helper'

RSpec.describe 'Projects', type: :request do
  let(:user) { create(:user) }
  let(:project_creator) { create(:user) }
  let(:project) { create(:project, project_creator_id: project_creator.id) }

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

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(project_creator)
  end

  describe 'POST /api/v1/users/:id/projects' do
    context 'when the user exists' do
      it 'creates a new project' do
        post "/api/v1/users/#{user.id}/projects", params: valid_attributes, headers: authenticated_headers(user)

        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Project Created Successfully')
        expect(json['project']['name']).to eq('New Project')
      end
    end

    context 'when the user does not exist' do
      it 'returns a not found error' do
        post "/api/v1/users/-1/projects", params: { project: { name: 'Invalid' } }, headers: authenticated_headers(user)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('User not found')
      end
    end
  end

  describe 'GET /api/v1/projects' do
    context 'when there are projects' do
      before do
        create_list(:project, 15, project_creator_id: project_creator.id) # Ensure you create enough projects
      end

      it 'returns a paginated list of projects' do
        get "/api/v1/projects", params: { page: 1 }, headers: authenticated_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json['projects'].size).to eq(10)
      end
    end

    context 'when there are no projects' do
      it 'returns an empty array' do
        get '/api/v1/projects', params: { page: 1, per_page: 10 }, headers: authenticated_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json['projects']).to eq([])
      end
    end
  end

  describe 'GET /api/v1/projects/:id' do
    context 'Shows the tasks of a project' do
      it 'returns the tasks of a project' do
        get "/api/v1/projects/#{project.id}", headers: authenticated_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json['tasks']).to be_a(Array)
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        get '/api/v1/projects/9999', headers: authenticated_headers(user)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Project not found')
      end
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    context 'when the project exists and belongs to the user' do
      it 'deletes the project' do
        delete "/api/v1/projects/#{project.id}", headers: authenticated_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Project deleted successfully')
      end
    end

    context 'when the project does not belong to the user' do
      let(:other_user) { create(:user) }

      it 'returns a forbidden error' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
        delete "/api/v1/projects/#{project.id}", headers: authenticated_headers(other_user)

        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        delete '/api/v1/projects/9999', headers: authenticated_headers(user)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Project not found')
      end
    end
  end

  describe 'PUT /api/v1/projects/:id' do
    context 'when the project exists and belongs to the user' do
      it 'updates the project' do
        valid_attributes = { project: { name: 'Updated Project' } }

        put "/api/v1/projects/#{project.id}", params: valid_attributes, headers: authenticated_headers(user)

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Project updated successfully')
        expect(json['project']['name']).to eq('Updated Project')
      end
    end

    context 'when the project does not belong to the user' do
      let(:other_user) { create(:user) }

      it 'returns a forbidden error' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)

        valid_attributes = { project: { name: 'Updated Project' } }

        put "/api/v1/projects/#{project.id}", params: valid_attributes, headers: authenticated_headers(other_user)

        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')
      end
    end

    context 'when the project does not exist' do
      it 'returns a not found error' do
        put '/api/v1/projects/9999', params: { project: { name: 'Some Name' } }, headers: authenticated_headers(user)

        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Project not found')
      end
    end
  end
end
