require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  # Create a user, assigned user, and a project for testing purposes
  let(:user) { create(:user) }
  let(:assigned_user) { create(:user) }
  let(:project) { create(:project) }
  
  # Create a task associated with the user, assigned user, and project
  let(:task) { create(:task, user: user, assigned_user: assigned_user, project: project) }
  
  # Generate authentication headers for the user
  let(:auth_headers) { authenticated_headers(user) }

  # Define valid attributes for creating a task
  let(:valid_attributes) { 
    { 
      task: { task_title: 'Sample11234', description: 'Sampe123-task description', assign_date: '2024-10-03', due_date: '2024-10-10', status: 'InProgress', priority: 'High' },
      assigned_user_id: assigned_user.id,
      project_id: project.id
    }
  }

  # Define invalid attributes for creating a task
  let(:invalid_attributes) { 
    { 
      task: { task_title: '', description: '', assign_date: '', due_date: '', status: '', priority: '' },
      assigned_user_id: nil,
      project_id: nil
    }
  }

  # Test for 'POST /api/v1/tasks' (Create Task)
  describe 'POST /api/v1/tasks' do
    context 'when valid parameters are provided' do
      it 'creates a new task' do
        post '/api/v1/tasks', params: valid_attributes, headers: auth_headers

        # Check for successful creation and response message
        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Task created successfully')
      end
    end

    context 'when assigned user is not found' do
      it 'returns a not found error' do
        invalid_attributes[:assigned_user_id] = nil  # Set assigned user to nil

        post '/api/v1/tasks', params: invalid_attributes, headers: auth_headers

        # Check for the correct error response
        expect(json['error']).to eq('Assigned user not found')
      end
    end

    context 'when project is not found' do
      it 'raises ProjectNotFoundError' do
        invalid_attributes[:project_id] = nil  # Set project ID to nil

        post '/api/v1/tasks', params: invalid_attributes, headers: auth_headers

        # Expect a 404 not found status
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Test for 'GET /api/v1/tasks' (Index: List all tasks)
  describe 'GET /api/v1/tasks' do
    context 'when tasks exist' do
      before do
        Comment.delete_all  # Ensure no comments exist before this test
        Task.delete_all  # Ensure no other tasks are present before the test
      end
      
      it 'returns all tasks' do
        create_list(:task, 5)  # Create 5 tasks for testing
        get '/api/v1/tasks', params: { page: 1, per_page: 10 }, headers: auth_headers

        # Check the response status and the number of tasks returned
        expect(response).to have_http_status(:ok)
        expect(json['tasks'].size).to eq(5)
      end
    end
    
    context 'when no tasks exist' do
      before do
        Comment.delete_all  # Ensure no comments exist before this test
        Task.delete_all  # Ensure no tasks exist before this test
      end
      
      it 'returns an empty array' do
        get '/api/v1/tasks', params: { page: 1, per_page: 10 }, headers: auth_headers

        # Check the response status and that the tasks array is empty
        expect(response).to have_http_status(:ok)
        expect(json['tasks']).to be_empty
      end
    end
  end

  # Test for 'DELETE /api/v1/tasks/:id' (Delete Task)
  describe 'DELETE /api/v1/tasks/:id' do
    let!(:user) { create(:user) }  # The user who will perform the deletion
    let!(:other_user) { create(:user) }  # Another user who doesn't own the task
    let!(:task) { create(:task, user: user) }  # Task owned by the user

    context 'when the task exists and the user is the owner' do
      before do
        # Ensure that the current user is the task owner
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      it 'deletes the task and returns status code 200' do
        delete "/api/v1/tasks/#{task.id}", headers: auth_headers  # Send delete request

        # Check that the response status is OK and the task is deleted
        expect(response).to have_http_status(:ok)
        expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)  # Task should be deleted
      end
    end

    context 'when the user is not the owner of the task' do
      before do
        # Ensure that the current user is not the task owner
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
      end

      it 'returns a 403 forbidden status' do
        delete "/api/v1/tasks/#{task.id}", headers: auth_headers  # Attempt to delete by another user

        # Check for a forbidden status
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the task is not found' do
      it 'returns a not found error' do
        delete '/api/v1/tasks/99999', headers: auth_headers  # Non-existing task

        # Check for a not found status
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Test for 'PUT /api/v1/tasks/:id' (Update Task)
  describe 'PUT /api/v1/tasks/:id' do
    let!(:user) { create(:user) }  # Task owner
    let!(:other_user) { create(:user) }  # Another user who doesn't own the task
    let!(:task) { create(:task, user: user) }  # Task owned by the user

    context 'when the task is not found' do
      it 'returns a not found error' do
        valid_attributes = { task: { task_title: 'Non-existent Task' } }

        put '/api/v1/tasks/99999', params: valid_attributes, headers: auth_headers  # Non-existing task

        # Check for a not found status
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is not the owner of the task' do
      before do
        # Ensure the current user is not the task owner
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(other_user)
      end

      it 'returns a forbidden error' do
        valid_attributes = { task: { task_title: 'Attempt to Update' } }

        put "/api/v1/tasks/#{task.id}", params: valid_attributes, headers: auth_headers

        # Check for a forbidden status and correct error message
        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to perform this action')
      end
    end
  end

  # Test for 'GET /api/v1/task/:id/comments' (List Comments for a Task)
  describe 'GET /api/v1/task/:id/comments' do
    let!(:task) { create(:task) }  # Create a task for testing

    context 'when task is not found' do
      it 'returns a not found error' do
        get '/api/v1/task/99999/comments', headers: auth_headers  # Non-existing task
        
        # Check for a not found status and correct error message
        expect(response).to have_http_status(:not_found)
        expect(json['error']).to eq('Task not found')
      end
    end

    context 'when task exists' do
      it 'returns the task comments' do
        comment = create(:comment, task: task)  # Create a comment for the task

        get "/api/v1/task/#{task.id}/comments", headers: auth_headers

        # Check the response status and that the correct comment is returned
        expect(response).to have_http_status(:ok)
        expect(json['comments'].size).to eq(1)  # Expect one comment in the response
        expect(json['comments'].first['text']).to eq(comment.text)  # Check the comment text
      end
    end
  end
end
