require 'rails_helper'

RSpec.describe "Users", type: :request do
  # Valid and invalid user parameters for testing
  let(:valid_user_params) { { user: { name: "John Doe", email: "john123444538@example.com", password: "password123", position: "Developer" } } }
  let(:invalid_user_params) { { user: { name: "", email: "invalid@example.com", password: "short", position: "" } } }
  
  # Create a user for authentication purposes
  let!(:user) { create(:user) }
  
  # Generate authentication headers for requests
  let(:auth_headers) { authenticated_headers(user) }

  # Test for 'POST /api/v1/users' (Create User)
  describe "POST /api/v1/users" do
    context "with valid parameters" do
      it "creates a new user and returns success message" do
        # Send POST request with valid user parameters
        post '/api/v1/users', params: valid_user_params

        # Expect the response to be successful (created)
        expect(response).to have_http_status(:created)
        # Expect the response message to indicate success
        expect(json['message']).to eq('User created successfully')
        # Expect the email in the response to match the created user
        expect(json['user']['email']).to eq('john123444538@example.com')
      end
    end

    context "with invalid parameters" do
      it 'does not create a user and returns an error message' do
        # Send POST request with invalid user parameters
        invalid_params = { user: { name: '', email: 'invalidemail', password: 'short' } }
        post '/api/v1/users', params: invalid_params
        
        # Expect the response to indicate unprocessable entity status
        expect(response).to have_http_status(:unprocessable_entity)
        # Expect error messages to be present in the response
        expect(json['errors']).to be_present
      end  
    end
  end

  # Test for 'GET /api/v1/users' (Index: List users with pagination)
  describe "GET /api/v1/users" do
    # Create a list of users for pagination testing
    let!(:users) { create_list(:user, 15) }

    it "returns a paginated list of users" do
      # Send GET request to retrieve the first page of users
      get '/api/v1/users',  params: { page: 1, per_page: 10 }, headers: auth_headers

      # Expect the response to be successful
      expect(response).to have_http_status(:ok)
      # Expect the response to return 10 users
      expect(json['users'].size).to eq(10) 
    end
  end

  # Test for 'GET /api/v1/users/projects' (User's Projects)
  describe "GET /api/v1/users/projects" do
    # Create a list of projects associated with the user
    let!(:projects) { create_list(:project, 3, users: [user]) }

    it "returns a list of the user's projects" do
      # Send GET request to retrieve the user's projects
      get '/api/v1/users/projects', headers: auth_headers

      # Expect the response to be successful
      expect(response).to have_http_status(:ok)
      # Expect the response to return 3 projects
      expect(json['projects'].size).to eq(3)
    end
  end

  # Test for 'GET /api/v1/users/tasks' (User's Tasks)
  describe "GET /api/v1/users/tasks" do
    # Create a user and associated tasks for testing
    let!(:user) { create(:user) }
    let!(:tasks) { create_list(:task, 3, assigned_user_id: user.id) }  # Ensure the tasks are assigned to the user
  
    before do
      # Mock the current_user method to return the user for testing
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)  
      # Send GET request to retrieve the user's tasks
      get "/api/v1/users/tasks", headers: auth_headers
    end

    it "returns a list of the user's tasks" do
      # Re-send GET request to retrieve the user's tasks
      get '/api/v1/users/tasks', headers: auth_headers

      # Expect the response to be successful
      expect(response).to have_http_status(:ok)
      # Expect the response to return 3 tasks
      expect(json['tasks'].size).to eq(3)
    end
  end
end
