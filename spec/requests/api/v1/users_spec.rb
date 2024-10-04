require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:valid_user_params) { { user: { name: "John Doe", email: "john@example.com", password: "password123", position: "Developer" } } }
  let(:invalid_user_params) { { user: { name: "", email: "invalid@example.com", password: "short", position: "" } } }
  let!(:user) { create(:user) }
  let(:auth_headers) { authenticated_headers(user) }

  # Test for 'POST /api/v1/users' (Create User)
  describe "POST /api/v1/users" do
    context "with valid parameters" do
      it "creates a new user and returns success message" do
        post '/api/v1/users', params: valid_user_params

        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('User created successfully')
        expect(json['user']['email']).to eq('john@example.com')
      end
    end

    context "with invalid parameters" do
      it 'does not create a user and returns an error message' do
        invalid_params = { user: { name: '', email: 'invalidemail', password: 'short' } }
        post '/api/v1/users', params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to be_present
      end
      
    end
  end

  # Test for 'GET /api/v1/users' (Index: List users with pagination)
  describe "GET /api/v1/users" do
    let!(:users) { create_list(:user, 15) }

    it "returns a paginated list of users" do
      get '/api/v1/users',  params: { page: 1, per_page: 10 }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(json['users'].size).to eq(10) 
    end
  end

  # Test for 'GET /api/v1/users/projects' (User's Projects)
  describe "GET /api/v1/users/projects" do
    let!(:projects) { create_list(:project, 3, users: [user]) }

    it "returns a list of the user's projects" do
      get '/api/v1/users/projects', headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(json['projects'].size).to eq(3)
    end
  end

  # Test for 'GET /api/v1/users/tasks' (User's Tasks)
  describe "GET /api/v1/users/tasks" do
    let!(:tasks) { create_list(:task, 3, user: user, project: create(:project)) }

    it "returns a list of the user's tasks" do
      get '/api/v1/users/tasks', headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(json['tasks'].size).to eq(3)
    end
  end
end
